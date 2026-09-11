# Pure policy builder shared by offline verification and the operator-only bootstrap.
function Get-MediaBootstrapPolicy {
    param([Parameter(Mandatory = $true)][object]$Config)
    $base = "/subscriptions/$($Config.subscriptionId)/resourceGroups/$($Config.resourceGroup)"
    $media = "$base/providers/Microsoft.Storage/storageAccounts/$($Config.mediaAccount)"
    $control = "$base/providers/Microsoft.Storage/storageAccounts/$($Config.controlAccount)"
    $blob = 'Microsoft.Storage/storageAccounts/blobServices/containers/blobs'
    $definitions = @()
    $grants = @()
    $operations = [ordered]@{
        dataReader = @("$blob/read")
        dataWriter = @("$blob/write")
        dataReadWriter = @("$blob/read", "$blob/write")
        dataManager = @("$blob/read", "$blob/write", "$blob/delete")
    }
    foreach ($entry in $operations.GetEnumerator()) {
        $definitions += @{
            id = "/subscriptions/$($Config.subscriptionId)/providers/Microsoft.Authorization/roleDefinitions/$($Config.roles.($entry.Key))"
            key = $entry.Key
            body = @{properties=@{
                roleName="$($Config.installationId)-$($entry.Key)";type='CustomRole'
                description='Pool blob operations only; assignment MUST constrain the container name with ABAC'
                assignableScopes=@($base)
                permissions=@(@{actions=@();notActions=@();dataActions=@($entry.Value);notDataActions=@()})
            }}
        }
    }
    $definitions += @{
        id = "/subscriptions/$($Config.subscriptionId)/providers/Microsoft.Authorization/roleDefinitions/$($Config.roles.containerManager)"
        key = 'containerManager'
        body = @{properties=@{
            roleName="$($Config.installationId)-container-manager";type='CustomRole'
            description='Create, inspect, set ACL and delete containers in this owned pool; no blob data, keys or RBAC'
            assignableScopes=@($base)
            permissions=@(@{
                actions=@('Microsoft.Storage/storageAccounts/blobServices/containers/read',
                    'Microsoft.Storage/storageAccounts/blobServices/containers/write',
                    'Microsoft.Storage/storageAccounts/blobServices/containers/delete')
                notActions=@();dataActions=@();notDataActions=@()
            })
        }}
    }
    # These are blob data operations, not container management or account-key access.
    # Lease/Put Block/Put Block List and conditional log replacement use blobs/write.
    $pool = @(
        @('widget', 'dataManager', 't-*-images'),
        @('widget', 'dataManager', 't-*-upload'),
        @('archive', 'dataWriter', 't-*-images'),
        @('archive', 'dataReadWriter', 't-*-upload'),
        @('rest', 'dataWriter', 't-*-images'),
        @('coordinator', 'dataManager', 't-*-upload'),
        @('imgproxy', 'dataReader', 't-*-images')
    )
    foreach ($grant in $pool) {
        $grants += @{
            role=$grant[0];definition=$Config.roles.($grant[1]);scope=$media
            conditionVersion='2.0'
            condition="(@Resource[Microsoft.Storage/storageAccounts/blobServices/containers:name] StringLike '$($grant[2])')"
        }
    }
    $tables = @(
        @('widget','directory','tableReader'), @('widget','credentials','tableReader'),
        @('widget','runtime','tableContributor'),
        @('archive','directory','tableReader'), @('archive','runtime','tableContributor'),
        @('rest','directory','tableReader'), @('rest','runtime','tableContributor'),
        @('coordinator','directory','tableReader'), @('coordinator','runtime','tableContributor'),
        @('coordinator','drain','tableContributor'),
        @('control-api','registry','tableContributor'),
        @('provisioner','registry','tableContributor'), @('provisioner','directory','tableContributor'),
        @('provisioner','credentials','tableContributor'),
        @('provisioner','drain','tableReader'), @('provisioner','proofs','tableReader')
    )
    foreach ($grant in $tables) {
        $grants += @{
            role=$grant[0];definition=$Config.roles.($grant[2])
            scope="$control/tableServices/default/tables/$($Config.tables.($grant[1]))"
        }
    }
    # Delegation cannot be constrained to a blob container; keep it separate from data grants.
    $grants += @{role='widget';definition=$Config.roles.blobDelegator;scope=$media}
    $grants += @{role='provisioner';definition=$Config.roles.containerManager;scope=$media}
    return @{definitions=$definitions;grants=$grants}
}

function Get-MediaAssignmentId {
    param([string]$PrincipalId, [string]$Definition, [string]$Scope, [string]$Condition)
    $hash = [System.Security.Cryptography.SHA256]::Create()
    try {
        $bytes = $hash.ComputeHash([Text.Encoding]::UTF8.GetBytes("$PrincipalId|$Definition|$Scope|$Condition".ToLowerInvariant()))
        return [guid]::new([byte[]]$bytes[0..15]).ToString()
    } finally { $hash.Dispose() }
}
