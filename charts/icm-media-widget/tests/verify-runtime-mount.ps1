[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$WidgetImage,
    [Parameter(Mandatory=$true)][string]$WorkerImage,
    [Parameter(Mandatory=$true)][string]$ControlPlaneImage
)
$ErrorActionPreference = 'Stop'
$chart = Split-Path $PSScriptRoot -Parent
Get-Command docker -ErrorAction Stop | Out-Null
Get-Command helm -ErrorAction Stop | Out-Null
function Assert-Mount {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
}
function Docker-Result {
    param([string[]]$Arguments)
    $old = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        $output = & docker @Arguments 2>&1
        $code = $LASTEXITCODE
    } finally { $ErrorActionPreference = $old }
    return @{ Code = $code; Output = ($output -join "`n") }
}
function Mount-Document {
    param([string]$Yaml, [string]$Kind, [string]$Name)
    $docs = @($Yaml -split '(?m)^---\s*$' | Where-Object {
        $_ -match "(?m)^kind: $Kind`r?$" -and $_ -match "(?m)^  name: $Name`r?$"
    })
    Assert-Mount ($docs.Count -eq 1) "Expected one $Kind/$Name"
    return $docs[0]
}
$yaml = & helm template fixture $chart --namespace fixture-media -f (Join-Path $PSScriptRoot 'values.yaml')
Assert-Mount ($LASTEXITCODE -eq 0) 'Cannot render mount fixture'
$yaml = $yaml -join "`n"
$id = 'media-mount-check-' + [guid]::NewGuid().ToString('N')
$scratch = Join-Path $PSScriptRoot ('.' + $id)
New-Item -ItemType Directory -Path $scratch | Out-Null
$cases = @(
    @{Role='widget'; Image=$WidgetImage; App='/work'; Entry='/work/start.sh'},
    @{Role='rest'; Image=$WorkerImage; App='/work'; Entry='/sbin/tini'},
    @{Role='provisioner'; Image=$ControlPlaneImage; App='/app'; Entry='java'}
)
try {
    foreach ($case in $cases) {
        $image = Docker-Result -Arguments @('image','inspect',$case.Image)
        Assert-Mount ($image.Code -eq 0) "Image must already exist locally (no pulls): $($case.Image)"
        $metadata = @($image.Output | ConvertFrom-Json)[0]
        Assert-Mount ($metadata.Config.Entrypoint[0] -eq $case.Entry) "Unexpected image entrypoint for $($case.Role)"
        if ($case.Role -eq 'rest') {
            Assert-Mount ($metadata.Config.Entrypoint -contains '-s') 'Worker image must retain its subreaper'
        }
        $deployment = Mount-Document $yaml 'Deployment' "fixture-media-$($case.Role)"
        $config = Mount-Document $yaml 'ConfigMap' "fixture-media-$($case.Role)"
        $mount = [regex]::Match($deployment, 'name: scratch, mountPath: ([^}\s]+)').Groups[1].Value
        Assert-Mount ($mount -eq '/media-runtime') 'Scratch must not overlay application files'
        $envArgs = @()
        foreach ($entry in @('JAVA_TOOL_OPTIONS','QUARKUS_HTTP_BODY_UPLOADS_DIRECTORY')) {
            $value = [regex]::Match($config, "(?m)^  ${entry}: `"([^`"]+)`"").Groups[1].Value
            Assert-Mount (-not [string]::IsNullOrEmpty($value)) "Missing rendered $entry"
            $envArgs += @('--env', "$entry=$value")
        }
        $options = @('--pull=never','--network=none','--read-only','--cap-drop=ALL',
            '--security-opt=no-new-privileges','--user=1000:1000',
            '--mount',"type=bind,source=$scratch,target=$mount") + $envArgs
        $check = 'test -r ' + $case.App + '/quarkus-run.jar; '
        if ($case.Role -eq 'widget') { $check += 'test -x /work/start.sh; ' }
        if ($case.Role -eq 'rest') { $check += 'test -x /sbin/tini; test -d /opt/native-child; ' }
        $check += 'mkdir -p "$QUARKUS_HTTP_BODY_UPLOADS_DIRECTORY"; printf writable > /media-runtime/mount-check; java -XshowSettings:properties -version'
        $probe = Docker-Result -Arguments (@('run','--rm') + $options + @('--entrypoint','/bin/sh',$case.Image,'-ec',$check))
        Assert-Mount ($probe.Code -eq 0 -and $probe.Output -match 'java.io.tmpdir = /media-runtime') "Mount/Java scratch probe failed for $($case.Role): $($probe.Output)"

        # Reproduce the old overlay failure; an empty writable app mount must hide the JAR.
        $hidden = Docker-Result -Arguments @('run','--rm','--pull=never','--network=none',
            '--read-only','--cap-drop=ALL','--security-opt=no-new-privileges','--user=1000:1000',
            '--mount',"type=bind,source=$scratch,target=$($case.App)",
            '--entrypoint','/bin/sh',$case.Image,'-ec',('test -r ' + $case.App + '/quarkus-run.jar'))
        Assert-Mount ($hidden.Code -ne 0) 'Overlay regression control unexpectedly found the application JAR'

        $container = "$id-$($case.Role)"
        try {
            # No entrypoint override: exercise the packaged launcher, including tini.
            $created = Docker-Result -Arguments (@('create','--name',$container) + $options +
                @('--env','QUARKUS_SCHEDULER_ENABLED=false',$case.Image))
            Assert-Mount ($created.Code -eq 0) "Cannot create launch probe: $($created.Output)"
            $started = Docker-Result -Arguments @('start',$container)
            Assert-Mount ($started.Code -eq 0) "Cannot launch packaged entrypoint: $($started.Output)"
            $booted = $false
            $logs = ''
            for ($attempt = 0; $attempt -lt 30; $attempt++) {
                Start-Sleep -Seconds 1
                $logs = (Docker-Result -Arguments @('logs',$container)).Output
                $booted = $logs -match 'Failed to start application|Failed to load config|started in .*Listening|Configuration validation failed'
                if ($booted) { break }
                $state = (Docker-Result -Arguments @('inspect','--format','{{.State.Running}}',$container)).Output
                if ($state -eq 'false') { break }
            }
            Assert-Mount ($logs -notmatch 'Unable to access jarfile|exec .*start.sh.*no such file|Permission denied') "Application hidden/unreadable: $logs"
            Assert-Mount $booted "Packaged bootstrap did not reach application initialization: $logs"
            Write-Output "PASS: $($case.Role) JAR/entrypoint visible, scratch writable, Java temp aligned; original launcher reached application initialization without network."
        } finally {
            $null = Docker-Result -Arguments @('rm','--force',$container)
        }
    }
} finally {
    if (Test-Path -LiteralPath $scratch) { Remove-Item -LiteralPath $scratch -Recurse -Force }
}
Write-Output 'PASS: three mount/launcher probes and three overlay-failure controls. Not a healthy-service, Kubernetes quota/fsGroup, sandbox or cloud acceptance test.'
$global:LASTEXITCODE = 0
