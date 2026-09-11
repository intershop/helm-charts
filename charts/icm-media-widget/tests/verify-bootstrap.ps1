[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$chart = Split-Path $PSScriptRoot -Parent
function Assert-Policy {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
}
# Even a regression past the default dry-run gate must not reach Azure in this test.
function az { throw 'Forbidden Azure invocation during offline tests' }
. (Join-Path $chart 'docs\bootstrap-policy.ps1')
$fixture = Join-Path $PSScriptRoot 'bootstrap.json'
$config = Get-Content -LiteralPath $fixture -Raw | ConvertFrom-Json
$policy = Get-MediaBootstrapPolicy $config
Assert-Policy ($policy.definitions.Count -eq 5 -and $policy.grants.Count -eq 25) 'Incomplete bootstrap policy'
$media = "/subscriptions/$($config.subscriptionId)/resourceGroups/$($config.resourceGroup)/providers/Microsoft.Storage/storageAccounts/$($config.mediaAccount)"
$expected = @(
    @('widget','dataManager','t-*-images','read,write,delete'),
    @('widget','dataManager','t-*-upload','read,write,delete'),
    @('archive','dataWriter','t-*-images','write'),
    @('archive','dataReadWriter','t-*-upload','read,write'),
    @('rest','dataWriter','t-*-images','write'),
    @('coordinator','dataManager','t-*-upload','read,write,delete'),
    @('imgproxy','dataReader','t-*-images','read')
)
$pool = @($policy.grants | Where-Object { $_.condition })
Assert-Policy ($pool.Count -eq $expected.Count) 'Pool policy must have exactly seven conditioned grants'
foreach ($entry in $expected) {
    $condition = "(@Resource[Microsoft.Storage/storageAccounts/blobServices/containers:name] StringLike '$($entry[2])')"
    $matches = @($pool | Where-Object { $_.role -eq $entry[0] -and $_.condition -eq $condition })
    Assert-Policy ($matches.Count -eq 1) "Missing/duplicated pool grant: $($entry[0]) $($entry[2])"
    $grant = $matches[0]
    Assert-Policy ($grant.scope -eq $media -and $grant.definition -eq $config.roles.($entry[1]) -and $grant.conditionVersion -eq '2.0') 'Wrong scope/role/ABAC version'
    $definition = @($policy.definitions | Where-Object { $_.key -eq $entry[1] })[0]
    $permissions = $definition.body.properties.permissions[0]
    $operations = @($permissions.dataActions | ForEach-Object { $_.Replace('Microsoft.Storage/storageAccounts/blobServices/containers/blobs/', '') }) -join ','
    Assert-Policy ($operations -ceq $entry[3] -and $permissions.actions.Count -eq 0) 'Data role is missing operations or has extra management/data permissions'
}
foreach ($pattern in @('t-*-images','t-*-upload')) {
    $suffix = $pattern.Substring(4)
    Assert-Policy ("t-00000000-0000-0000-0000-000000000099-$suffix" -clike $pattern) 'Future container missing from pool pattern'
    Assert-Policy ("legacy-$suffix" -cnotlike $pattern) 'Pool pattern admits legacy containers'
}
$unconditionalMedia = @($policy.grants | Where-Object { $_.scope -eq $media -and -not $_.condition })
Assert-Policy ($unconditionalMedia.Count -eq 2) 'Unconditioned media data grant detected'
Assert-Policy (@($unconditionalMedia | Where-Object { $_.role -eq 'widget' -and $_.definition -eq $config.roles.blobDelegator }).Count -eq 1) 'Delegation must be separately assigned only to widget'
Assert-Policy (@($unconditionalMedia | Where-Object { $_.role -eq 'provisioner' -and $_.definition -eq $config.roles.containerManager }).Count -eq 1) 'Only provisioner may manage pool containers'
$manager = @($policy.definitions | Where-Object { $_.key -eq 'containerManager' })[0].body.properties.permissions[0]
Assert-Policy ($manager.dataActions.Count -eq 0 -and $manager.actions.Count -eq 3 -and @($manager.actions | Where-Object { $_ -notmatch '^Microsoft.Storage/storageAccounts/blobServices/containers/(read|write|delete)$' }).Count -eq 0) 'Container manager has broader permissions'
$drain = @($policy.grants | Where-Object { $_.scope.EndsWith('/tables/TenantDrain') })
Assert-Policy ($drain.Count -eq 2) 'Drain must have exactly two grants'
Assert-Policy (@($drain | Where-Object { $_.role -eq 'coordinator' -and $_.definition -eq $config.roles.tableContributor }).Count -eq 1) 'Coordinator must be sole drain writer'
Assert-Policy (@($drain | Where-Object { $_.role -eq 'provisioner' -and $_.definition -eq $config.roles.tableReader }).Count -eq 1) 'Provisioner must only read drain'
foreach ($role in @('widget','archive','rest','coordinator')) {
    Assert-Policy (@($policy.grants | Where-Object { $_.role -eq $role -and $_.scope.EndsWith('/tables/TenantRuntime') -and $_.definition -eq $config.roles.tableContributor }).Count -eq 1) "Missing runtime admission grant: $role"
}
$proofs = @($policy.grants | Where-Object { $_.scope.EndsWith('/tables/TenantProofs') })
Assert-Policy ($proofs.Count -eq 1 -and $proofs[0].role -eq 'provisioner' -and $proofs[0].definition -eq $config.roles.tableReader) 'Applications may not write proofs'
$apiGrants = @($policy.grants | Where-Object { $_.role -eq 'control-api' })
Assert-Policy ($apiGrants.Count -eq 1 -and $apiGrants[0].scope.EndsWith('/tables/TenantRegistry')) 'Portal API must not publish projections or access media/runtime records'
$id = Get-MediaAssignmentId 'principal' 'definition' $media 'condition'
Assert-Policy ($id -eq (Get-MediaAssignmentId 'principal' 'definition' $media 'condition')) 'Assignment IDs must be reproducible'
Assert-Policy ($id -ne (Get-MediaAssignmentId 'principal' 'definition' $media 'other-condition')) 'Different conditioned grants must have separate IDs'
$output = & (Join-Path $chart 'docs\bootstrap.ps1') -InputFile $fixture
Assert-Policy (($output -join "`n") -match 'NO AZURE COMMANDS EXECUTED') 'Bootstrap must default to offline dry-run'
$scratch = Join-Path $PSScriptRoot ('.bootstrap-test-' + [guid]::NewGuid().ToString() + '.json')
try {
    foreach ($case in @('shared-drain','missing-drain','shared-data-role')) {
        $invalid = Get-Content -LiteralPath $fixture -Raw | ConvertFrom-Json
        switch ($case) {
            'shared-drain' { $invalid.tables.drain = $invalid.tables.runtime }
            'missing-drain' { $invalid.tables.PSObject.Properties.Remove('drain') }
            'shared-data-role' { $invalid.roles.dataReader = $invalid.roles.dataManager }
        }
        $invalid | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $scratch
        $rejected = $false
        try { $null = & (Join-Path $chart 'docs\bootstrap.ps1') -InputFile $scratch } catch { $rejected = $true }
        Assert-Policy $rejected "Unsafe bootstrap input accepted: $case"
    }
} finally { if (Test-Path -LiteralPath $scratch) { Remove-Item -LiteralPath $scratch } }
Write-Output 'PASS: offline bootstrap dry-run; exact ABAC operations, future pool patterns, deterministic assignments, drain/proof isolation, three invalid fixtures. No Azure commands.'
