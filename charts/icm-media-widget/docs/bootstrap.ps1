<#
Creates only reviewed platform infrastructure, never tenant records or media data.
Not executed during implementation. Run from the chart directory with an approved
non-secret JSON input file. Default is validation only; -Apply is deliberately required.
#>
[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
param(
    [Parameter(Mandatory = $true)][string]$InputFile,
    [switch]$Apply
)
$ErrorActionPreference = 'Stop'
$c = Get-Content -LiteralPath $InputFile -Raw | ConvertFrom-Json
$required = @('subscriptionId','tenantId','resourceGroup','resourceGroupRegion',
    'mediaRegion','controlRegion','mediaAccount','controlAccount','sku',
    'installationId','aksOidcIssuer','namespace','fullname','armEndpoint',
    'approvedOrigins','controlAllowedIps','blobSoftDeleteDays','containerSoftDeleteDays',
    'corsMaxAgeSeconds','tables','identities','roles','approvedCompanyTenant','companyIssuer')
foreach ($field in $required) {
    if (-not $c.PSObject.Properties[$field] -or [string]::IsNullOrWhiteSpace([string]$c.$field)) {
        throw "Required input: $field"
    }
}
foreach ($field in @('subscriptionId','tenantId','approvedCompanyTenant')) {
    $parsed = [guid]::Empty
    if (-not [guid]::TryParse($c.$field, [ref]$parsed) -or $parsed -eq [guid]::Empty) {
        throw "$field must be an explicit nonzero UUID"
    }
}
foreach ($field in @('mediaAccount','controlAccount')) {
    if ($c.$field -cnotmatch '^[a-z0-9]{3,24}$') { throw "Invalid account: $field" }
}
if ($c.mediaAccount -eq $c.controlAccount) { throw 'Two separate accounts are required' }
foreach ($field in @('aksOidcIssuer','armEndpoint','companyIssuer')) {
    $uri = [uri]$c.$field
    if ($uri.Scheme -ne 'https' -or $uri.UserInfo -or $uri.Query -or $uri.Fragment) {
        throw "Invalid HTTPS endpoint: $field"
    }
}
if ($c.fullname -cnotmatch '^[a-z0-9]([-a-z0-9]{0,38}[a-z0-9])?$') { throw 'fullname must match the chart fullnameOverride (maximum 40 characters)' }
if ($c.namespace -cnotmatch '^[a-z0-9]([-a-z0-9]*[a-z0-9])?$') { throw 'Invalid namespace' }
foreach ($origin in $c.approvedOrigins) {
    if ($origin -cnotmatch '^https://[a-zA-Z0-9.-]+(:[0-9]+)?$') { throw 'Only exact HTTPS origins are allowed' }
}
if (@($c.approvedOrigins).Count -lt 1 -or @($c.approvedOrigins).Count -gt 64) { throw 'Review Azure CORS limits; use an approved shared origin when necessary' }
if (@($c.controlAllowedIps).Count -lt 1) { throw 'Control firewall must include explicit operator and cluster egress IPv4 ranges' }
foreach ($ip in $c.controlAllowedIps) {
    if ($ip -notmatch '^\d{1,3}(\.\d{1,3}){3}(/\d{1,2})?$' -or $ip -eq '0.0.0.0/0') { throw "Invalid or unrestricted control firewall range: $ip" }
}
foreach ($field in @('blobSoftDeleteDays','containerSoftDeleteDays')) {
    if ([int]$c.$field -lt 1 -or [int]$c.$field -gt 365) { throw "Review retention: $field must be 1..365" }
}
if ([int]$c.corsMaxAgeSeconds -lt 1 -or [int]$c.corsMaxAgeSeconds -gt 3600) { throw 'CORS max age must be 1..3600' }
$roles = @('widget','archive','rest','coordinator','control-api','provisioner','imgproxy')
foreach ($role in $roles) {
    if (-not $c.identities.PSObject.Properties[$role] -or $c.identities.$role -notmatch '^[a-zA-Z0-9_-]+$') { throw "Missing identity name: $role" }
}
if (@($c.identities.PSObject.Properties.Value | Select-Object -Unique).Count -ne 7) { throw 'Exactly seven distinct identities required' }
foreach ($table in @('registry','directory','credentials','runtime','drain','proofs')) {
    if ($c.tables.$table -cnotmatch '^[A-Za-z][A-Za-z0-9]{2,62}$') { throw "Missing/invalid table: $table" }
}
if (@($c.tables.PSObject.Properties).Count -ne 6 -or @($c.tables.PSObject.Properties.Value | ForEach-Object { $_.ToLowerInvariant() } | Select-Object -Unique).Count -ne 6) { throw 'Six distinct tables required' }
$roleKeys = @('tableReader','tableContributor','blobDelegator','containerManager','dataReader','dataWriter','dataReadWriter','dataManager')
foreach ($role in $roleKeys) {
    $parsed = [guid]::Empty
    if (-not [guid]::TryParse($c.roles.$role, [ref]$parsed) -or $parsed -eq [guid]::Empty) { throw "Missing role-definition UUID: $role" }
}
if (@($c.roles.PSObject.Properties).Count -ne $roleKeys.Count -or @($c.roles.PSObject.Properties.Value | Select-Object -Unique).Count -ne $roleKeys.Count) { throw 'Eight distinct approved role IDs required' }
. (Join-Path $PSScriptRoot 'bootstrap-policy.ps1')
$policy = Get-MediaBootstrapPolicy -Config $c
if (-not $Apply) {
    $policy | ConvertTo-Json -Depth 20
    Write-Output 'Inputs validated. NO AZURE COMMANDS EXECUTED. Review AZURE-BOOTSTRAP.md; -Apply requires explicit operator approval.'
    return
}
if (-not $PSCmdlet.ShouldProcess("$($c.subscriptionId)/$($c.resourceGroup)", 'Create/update reviewed platform resources (NO tenant data migration)')) { return }
Get-Command az -ErrorAction Stop | Out-Null
function Invoke-Azure {
    param([string[]]$Arguments)
    $result = & az @Arguments --subscription $c.subscriptionId --only-show-errors --output json
    if ($LASTEXITCODE -ne 0) { throw "Azure command failed: $($Arguments[0..1] -join ' '); stop and reconcile before retry" }
    if ($result) { return ($result -join "`n" | ConvertFrom-Json) }
}
$context = Invoke-Azure -Arguments @('account','show')
if ($context.tenantId -ne $c.tenantId -or $context.id -ne $c.subscriptionId) { throw 'Existing Azure CLI login does not match approved subscription/tenant. No automatic login.' }
$base = "/subscriptions/$($c.subscriptionId)/resourceGroups/$($c.resourceGroup)"
$mediaId = "$base/providers/Microsoft.Storage/storageAccounts/$($c.mediaAccount)"
$controlId = "$base/providers/Microsoft.Storage/storageAccounts/$($c.controlAccount)"
$arm = $c.armEndpoint.TrimEnd('/')
$artifact = Join-Path (Get-Location) '.bootstrap-artifacts'
New-Item -ItemType Directory -Path $artifact -Force | Out-Null
function Put-Resource {
    param([string]$Id, [object]$Body, [string]$Version, [string]$FileName)
    $file = Join-Path $artifact $FileName
    $Body | ConvertTo-Json -Depth 30 | Set-Content -LiteralPath $file -Encoding UTF8
    Invoke-Azure -Arguments @('rest','--method','put','--url',"$arm${Id}?api-version=$Version",'--body',"@$file") | Out-Null
}
Invoke-Azure -Arguments @('group','create','--name',$c.resourceGroup,'--location',$c.resourceGroupRegion,'--tags',"media-installation=$($c.installationId)") | Out-Null
# A fresh installation only: do not adopt/update any existing storage account implicitly.
$existing = Invoke-Azure -Arguments @('storage','account','list','--resource-group',$c.resourceGroup)
foreach ($account in $existing) {
    if ($account.name -in @($c.mediaAccount,$c.controlAccount) -and $account.tags.'media-installation' -ne $c.installationId) {
        throw 'An account already exists without this installation ownership tag; refusing adoption'
    }
}
foreach ($item in @(@{name=$c.mediaAccount;region=$c.mediaRegion;public='true';firewall='Allow'}, @{name=$c.controlAccount;region=$c.controlRegion;public='false';firewall='Deny'})) {
    Invoke-Azure -Arguments @('storage','account','create','--name',$item.name,'--resource-group',$c.resourceGroup,
        '--location',$item.region,'--sku',$c.sku,'--kind','StorageV2','--https-only','true',
        '--min-tls-version','TLS1_2','--allow-shared-key-access','false','--allow-blob-public-access',$item.public,
        '--public-network-access','Enabled','--default-action',$item.firewall,'--bypass','None',
        '--tags',"media-installation=$($c.installationId)") | Out-Null
}
foreach ($ip in $c.controlAllowedIps) {
    Invoke-Azure -Arguments @('storage','account','network-rule','add','--account-name',$c.controlAccount,
        '--resource-group',$c.resourceGroup,'--ip-address',$ip) | Out-Null
}
$cors = @{
    allowedOrigins=@($c.approvedOrigins); allowedMethods=@('PUT','GET','HEAD','OPTIONS')
    allowedHeaders=@('content-type','x-ms-*'); exposedHeaders=@('ETag','x-ms-request-id','x-ms-version')
    maxAgeInSeconds=[int]$c.corsMaxAgeSeconds
}
Put-Resource "$mediaId/blobServices/default" @{properties=@{
    cors=@{corsRules=@($cors)}; isVersioningEnabled=$true
    deleteRetentionPolicy=@{enabled=$true;days=[int]$c.blobSoftDeleteDays}
    containerDeleteRetentionPolicy=@{enabled=$true;days=[int]$c.containerSoftDeleteDays}
}} '2023-05-01' 'media-blob-policy.json'
foreach ($table in $c.tables.PSObject.Properties.Value) {
    Put-Resource "$controlId/tableServices/default/tables/$table" @{properties=@{}} '2023-05-01' "table-$table.json"
}
$identities = @{}
foreach ($role in $roles) {
    $identity = Invoke-Azure -Arguments @('identity','create','--name',$c.identities.$role,'--resource-group',$c.resourceGroup,
        '--location',$c.resourceGroupRegion,'--tags',"media-installation=$($c.installationId)")
    $identities[$role] = $identity
    Invoke-Azure -Arguments @('identity','federated-credential','create','--name',"$($c.fullname)-$role",
        '--identity-name',$c.identities.$role,'--resource-group',$c.resourceGroup,
        '--issuer',$c.aksOidcIssuer,'--subject',"system:serviceaccount:$($c.namespace):$($c.fullname)-$role",
        '--audiences','api://AzureADTokenExchange') | Out-Null
}
foreach ($definition in $policy.definitions) {
    Put-Resource $definition.id $definition.body '2022-04-01' "$($definition.key)-role.json"
}
foreach ($grant in $policy.grants) {
    $principal = $identities[$grant.role].principalId
    $assignment = Get-MediaAssignmentId $principal $grant.definition $grant.scope $grant.condition
    $properties = @{
        principalId=$principal;principalType='ServicePrincipal'
        roleDefinitionId="/subscriptions/$($c.subscriptionId)/providers/Microsoft.Authorization/roleDefinitions/$($grant.definition)"
    }
    if ($grant.condition) {
        $properties.condition = $grant.condition
        $properties.conditionVersion = $grant.conditionVersion
    }
    Put-Resource "$($grant.scope)/providers/Microsoft.Authorization/roleAssignments/$assignment" @{properties=$properties} '2022-04-01' "assignment-$assignment.json"
}
$identityOutput = @{}
foreach ($role in $roles) {
    $identityOutput[$role] = @{clientId=$identities[$role].clientId;principalId=$identities[$role].principalId;resourceId=$identities[$role].id}
}
$identityOutput | ConvertTo-Json -Depth 5 | Set-Content (Join-Path $artifact 'identity-outputs.json') -Encoding UTF8
Write-Output 'Platform bootstrap and ABAC pool grants completed. Effective permissions/CORS/isolation are NOT proven. Operator pool-access attestation or per-tenant proofs are still required. Production cutover remains BLOCKED.'
