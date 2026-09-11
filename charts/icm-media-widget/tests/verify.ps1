[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$chart = Split-Path $PSScriptRoot -Parent
$fixture = Join-Path $PSScriptRoot 'values.yaml'
Get-Command helm -ErrorAction Stop | Out-Null
function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
}
function Render {
    param([string[]]$Extra = @())
    $result = & helm template fixture $chart --namespace fixture-media -f $fixture @Extra 2>&1
    Assert-True ($LASTEXITCODE -eq 0) ($result -join "`n")
    return ($result -join "`n")
}
function Document {
    param([string]$Yaml, [string]$Kind, [string]$Name)
    $found = @($Yaml -split '(?m)^---\s*$' | Where-Object {
        $_ -match "(?m)^kind: $Kind`r?$" -and $_ -match "(?m)^  name: $Name`r?$"
    })
    Assert-True ($found.Count -eq 1) "Expected one $Kind/$Name"
    return $found[0]
}
& helm lint $chart --strict -f $fixture
Assert-True ($LASTEXITCODE -eq 0) 'Helm lint failed'
$rendered = Render
foreach ($pair in @(@('Deployment',7),@('ServiceAccount',7),@('NetworkPolicy',7),@('Ingress',3),@('ConfigMap',6),@('ScaledObject',1),@('Service',5))) {
    Assert-True (([regex]::Matches($rendered, "(?m)^kind: $($pair[0])`r?$")).Count -eq $pair[1]) "Wrong resource count: $($pair[0])"
}
Assert-True ($rendered -notmatch 'HTTPScaledObject|azure-blob|connectionFromEnv|IMGPROXY_ABS_KEY|AZURE_CLIENT_SECRET|kind: Secret\b|/insecure/') 'Legacy scaling or inline secrets detected'
Assert-True ($rendered -notmatch '(TENANCY|MEDIA|QUARKUS)_[A-Z_]+: "[0-9.]+e[+-][0-9]+"') 'Application numeric limits must render as decimal integers, not scientific notation'
$coordinator = Document $rendered 'Deployment' 'fixture-media-coordinator'
Assert-True ($coordinator -match '(?m)^  replicas: 1$') 'Coordinator must stay running'
$rest = Document $rendered 'ConfigMap' 'fixture-media-rest'
Assert-True ($rest -match 'MEDIA_ROLE: "rest"') 'REST role is not exclusive'
$scaler = Document $rendered 'ScaledObject' 'fixture-media-archive'
Assert-True ($scaler -match 'coordinator\.fixture-media\.svc:8080/internal/backlog' -and $scaler -match 'valueLocation: metricValue') 'Wrong coordinator activation contract'
Assert-True ($scaler -match 'fallback:' -and $scaler -match 'stabilizationWindowSeconds: 300') 'Failure fallback or stabilization missing'
$proxy = Document $rendered 'Deployment' 'fixture-media-imgproxy'
Assert-True ($proxy -match 'WorkloadIdentityCredential' -and $proxy -match 'abs://t-\*-images/' -and $proxy -match 'secretKeyRef:') 'imgproxy credential/source restrictions missing'
Assert-True ($proxy -match 'IMGPROXY_MAX_SRC_FILE_SIZE, value: "26214400"') 'imgproxy byte limit must render as a decimal integer'
Assert-True ($proxy -match 'path: /imgproxy/health' -and $rendered -notmatch '/q/health/started') 'Probe paths must be accepted by pinned router and widget authentication'
$public = Document $rendered 'Ingress' 'fixture-media-public'
Assert-True ($public -match 'path: /mediawidget/public/tenants/' -and $public -match '/imgproxy/' -and $public -notmatch '(?m)^\s+- path: /$') 'Public ingress exposes management or misses widget root'
Assert-True ((Document $rendered 'Ingress' 'fixture-media-management') -match 'path: /mediawidget') 'Management ingress must preserve widget root'
$widgetConfig = Document $rendered 'ConfigMap' 'fixture-media-widget'
Assert-True ($widgetConfig -match 'TENANCY_PUBLIC_BASE_URL: "https://images.invalid/mediawidget"' -and $widgetConfig -match 'TENANCY_IMGPROXY_BASE_URL: "https://images.invalid/imgproxy"') 'Widget public bases are wrong'
foreach ($role in @('widget','archive','rest','coordinator','control-api','provisioner')) {
    $config = Document $rendered 'ConfigMap' "fixture-media-$role"
    $deployment = Document $rendered 'Deployment' "fixture-media-$role"
    $root = '/'
    if ($role -eq 'widget') { $root = '/mediawidget' }
    Assert-True ($config -match ('QUARKUS_HTTP_ROOT_PATH: "' + $root + '"')) "Incorrect HTTP root: $role"
    Assert-True ($config -match 'JAVA_TOOL_OPTIONS: "-Djava.io.tmpdir=/media-runtime"' -and $config -match 'QUARKUS_HTTP_BODY_UPLOADS_DIRECTORY: "/media-runtime/uploads"') "Unwritable scratch directory: $role"
    Assert-True ($deployment -match 'readOnlyRootFilesystem: true' -and $deployment -match 'mountPath: /media-runtime' -and $deployment -notmatch '/tmp|medium: Memory') "Read-only/scratch mount incorrect: $role"
    Assert-True ($deployment -notmatch 'mountPath:\s*["'']?/(work|app|opt)(/|["''},\s]|$)') "Scratch hides application binaries or native helper: $role"
    Assert-True ($deployment -match 'ephemeral-storage:' -and $deployment -match 'emptyDir: \{sizeLimit: "[1-9][0-9]*"\}') "Missing bounded disk scratch/resource budget: $role"
    if ($role -eq 'provisioner') {
        Assert-True ($config -match 'QUARKUS_HTTP_HOST: "127.0.0.1"' -and $config -match 'PERMISSION__APPLICATION__POLICY: "deny"' -and $config -match 'PERMISSION__HEALTH__PATHS: "/q/health,/q/health/\*"') 'Provisioner loopback/deny-all/local health configuration missing'
        Assert-True ($deployment -notmatch 'httpGet:' -and ([regex]::Matches($deployment, '\["java", "-cp", "/app/app/\*", "com.intershop.cdn.controlplane.HealthProbe"(, "ready")?\]')).Count -eq 3 -and $deployment -match '"HealthProbe", "ready"|"com.intershop.cdn.controlplane.HealthProbe", "ready"') 'Provisioner must use local Java live and readiness probes'
        Assert-True (@($rendered -split '(?m)^---\s*$' | Where-Object { $_ -match '(?m)^kind: Service$' -and $_ -match 'name: fixture-media-provisioner' }).Count -eq 0) 'Provisioner must not have a Service'
    } else {
        $health = '/q/health'
        if ($role -eq 'widget') { $health = '/mediawidget/q/health' }
        Assert-True ($config -match 'QUARKUS_HTTP_HOST: "0.0.0.0"' -and $deployment -match "path: $health/live" -and $deployment -match "path: $health/ready" -and $deployment -notmatch 'exec:') "Wrong HTTP probes: $role"
    }
    if ($role -eq 'coordinator') {
        Assert-True ($config -match 'TENANCY_DRAIN_TABLE: "TenantDrain"') 'Coordinator drain table missing'
    } elseif ($role -eq 'provisioner') {
        Assert-True ($config -match 'CONTROL_DRAIN_TABLE: "TenantDrain"') 'Provisioner drain table missing'
    } else {
        Assert-True ($config -notmatch '(TENANCY|CONTROL)_DRAIN_TABLE:') "Drain configuration leaked to $role"
    }
}
Assert-True ($proxy -match 'mountPath: /media-runtime' -and $proxy -match 'name: TMPDIR, value: "/media-runtime"' -and $proxy -notmatch '/tmp|mountPath: /work') 'imgproxy scratch must use the separate runtime directory'
$archivePolicy = Document $rendered 'NetworkPolicy' 'fixture-media-archive'
Assert-True ($archivePolicy -match 'ingress: \[\]') 'Archive ingress not closed'
$restPolicy = Document $rendered 'NetworkPolicy' 'fixture-media-rest'
Assert-True ($restPolicy -match 'app.kubernetes.io/component: widget' -and $restPolicy -notmatch 'fixture-ingress') 'REST not widget-only'
foreach ($role in @('archive','rest','coordinator')) {
    Assert-True ((Document $rendered 'ConfigMap' "fixture-media-$role") -notmatch 'CREDENTIALS_TABLE|CONTROL_REGISTRY_TABLE') "Worker $role receives control/credential table configuration"
    $config = Document $rendered 'ConfigMap' "fixture-media-$role"
    Assert-True ($config -match 'MEDIA_LOCAL_CONCURRENCY: "1"' -and $config -match 'MEDIA_LOCAL_PER_TENANT_CONCURRENCY: "1"' -and $config -match 'MEDIA_MAX_IMAGE_OUTPUT_BYTES: "26214400"' -and $config -match 'MEDIA_NATIVE_HEAP_MB: "256"' -and $config -match 'MEDIA_NATIVE_ADDRESS_SPACE_BYTES: "2147483648"') "Missing bounded native worker settings: $role"
    Assert-True ((Document $rendered 'Deployment' "fixture-media-$role") -notmatch '(?m)^          (command|args):') "Worker image subreaper entrypoint must not be overridden: $role"
}
$changed = Render -Extra @('--set','components.controlApi.image.tag=2.0.1','--set','oidc.issuer=https://identity.invalid/updated-company')
foreach ($role in @('widget','archive','rest','coordinator','provisioner','imgproxy')) {
    Assert-True ((Document $rendered 'Deployment' "fixture-media-$role") -eq (Document $changed 'Deployment' "fixture-media-$role")) "Portal-only change rolls $role"
}
Assert-True ((Document $rendered 'Deployment' 'fixture-media-control-api') -ne (Document $changed 'Deployment' 'fixture-media-control-api')) 'Control API update is missing'
$fixed = Render -Extra @('--set','scaling.enabled=false','--set','components.archive.replicas=2')
Assert-True ($fixed -notmatch 'kind: ScaledObject' -and (Document $fixed 'Deployment' 'fixture-media-archive') -match '(?m)^  replicas: 2$') 'Fixed archive replica option failed'
$httpArgs = @('-f', (Join-Path $PSScriptRoot 'http-scaling.yaml'), '--kube-version', '1.32.0')
& helm lint $chart --strict -f $fixture @httpArgs
Assert-True ($LASTEXITCODE -eq 0) 'HTTP scaling Helm lint failed'
$http = Render -Extra $httpArgs
Assert-True (([regex]::Matches($http, '(?m)^kind: HTTPScaledObject$')).Count -eq 2) 'Both HTTPScaledObjects must render'
Assert-True (([regex]::Matches($http, '(?m)^kind: ScaledObject$')).Count -eq 1 -and $http -notmatch 'kind: HorizontalPodAutoscaler') 'HTTP add-on must be the only owner of its generated ScaledObjects/HPAs'
Assert-True ($http -notmatch 'targetPendingRequests:|deployment:|kind: CustomResourceDefinition') 'Obsolete HTTP API or chart-installed CRDs detected'
foreach ($role in @('widget','rest')) {
    $hso = Document $http 'HTTPScaledObject' "fixture-media-$role"
    Assert-True ($hso -match 'apiVersion: http.keda.sh/v1alpha1' -and $hso -match 'skip-scaledobject-creation: "false"') "Incorrect add-on ownership: $role"
    Assert-True ($hso -match "name: fixture-media-$role" -and $hso -match "service: fixture-media-$role" -and $hso -match 'kind: Deployment' -and $hso -match 'apiVersion: apps/v1' -and $hso -match 'port: 8080') "Incorrect HTTP scale target: $role"
    Assert-True ($hso -match 'scalingMetric:\s+concurrency:\s+targetValue:' -and $hso -match 'scaledownPeriod: 600' -and $hso -match 'conditionWait: "20s"' -and $hso -match 'responseHeader: "630s"') "Incorrect HTTP metric/timeouts: $role"
    Assert-True ((Document $http 'Deployment' "fixture-media-$role") -notmatch '(?m)^  replicas:') "Helm must not fight HTTP scaling: $role"
    $alias = Document $http 'Service' "fixture-media-$role-interceptor"
    Assert-True ($alias -match 'type: ExternalName' -and $alias -match 'externalName: "fixture-http-interceptor-proxy.fixture-http.svc.cluster.local"' -and $alias -notmatch 'selector:') "Incorrect interceptor alias: $role"
    $policy = Document $http 'NetworkPolicy' "fixture-media-$role"
    $ingressPolicy = ($policy -split '(?m)^  egress:')[0]
    Assert-True ($ingressPolicy -match 'kubernetes.io/metadata.name: fixture-http' -and $ingressPolicy -match 'app.kubernetes.io/component: interceptor' -and $ingressPolicy -notmatch 'fixture-ingress') "HTTP backend permits interceptor bypass: $role"
    Assert-True ((Document $http 'Service' "fixture-media-$role") -match "app.kubernetes.io/component: $role") "HTTP target must remain a backend Service, not an alias: $role"
}
$httpWidget = Document $http 'HTTPScaledObject' 'fixture-media-widget'
Assert-True ($httpWidget -match 'min: 1\s+max: 1' -and $httpWidget -match '"images.invalid"' -and $httpWidget -match '"management.invalid"' -and $httpWidget -match '"/mediawidget"') 'Stateful widget routing/bounds unsafe'
Assert-True ((Document $http 'Deployment' 'fixture-media-widget') -match 'strategy: \{type: Recreate\}') 'Widget rollout must not temporarily load-balance pod-local sessions across two replicas'
$httpRest = Document $http 'HTTPScaledObject' 'fixture-media-rest'
Assert-True ($httpRest -match 'min: 0\s+max: 4' -and $httpRest -match '"fixture-media-rest-interceptor.fixture-media.svc.cluster.local"' -and $httpRest -match '"/api/tenants/"' -and $httpRest -notmatch 'images.invalid|management.invalid|control.invalid|/internal|/q/health') 'REST route must stay internal and tenant-qualified'
$httpConfig = Document $http 'ConfigMap' 'fixture-media-widget'
Assert-True (([regex]::Matches($httpConfig, 'http://fixture-media-rest-interceptor.fixture-media.svc.cluster.local:8080')).Count -eq 2) 'Both worker client URLs must go through the interceptor with the matching Host'
foreach ($route in @('public','management')) {
    $ingress = Document $http 'Ingress' "fixture-media-$route"
    Assert-True ($ingress -match 'name: fixture-media-widget-interceptor' -and $ingress -notmatch 'fixture-media-rest|/api/tenants/|/internal/') 'HTTP scaling exposes resize or bypasses interception'
}
Assert-True ((Document $http 'Ingress' 'fixture-media-public') -match 'name: fixture-media-imgproxy') 'Signed imgproxy must bypass widget HTTP scaling'
$widgetPolicy = Document $http 'NetworkPolicy' 'fixture-media-widget'
Assert-True ($widgetPolicy -notmatch 'app.kubernetes.io/component: rest') 'Widget must not bypass REST interception'
$restIngressPolicy = (Document $http 'NetworkPolicy' 'fixture-media-rest') -split '(?m)^  egress:'
Assert-True ($restIngressPolicy[0] -notmatch 'app.kubernetes.io/component: widget') 'REST backend accepts uncounted direct widget requests'
foreach ($role in @('archive','coordinator','control-api','provisioner','imgproxy')) {
    Assert-True ((Document $http 'Deployment' "fixture-media-$role") -eq (Document $rendered 'Deployment' "fixture-media-$role")) "HTTP changes roll unrelated $role"
}
Assert-True ((Document $http 'ScaledObject' 'fixture-media-archive') -eq $scaler) 'HTTP scaling changes archive KEDA'
$httpRestConfig = Document $http 'ConfigMap' 'fixture-media-rest'
Assert-True (($httpRestConfig -replace '(?m)^  QUARKUS_SHUTDOWN_TIMEOUT: "630s"\r?\n', '') -eq $rest -and (Document $http 'Deployment' 'fixture-media-rest') -match 'secretName: fixture-worker-verification') 'REST JWT/role contracts changed'
Assert-True ($httpRestConfig -match 'QUARKUS_SHUTDOWN_TIMEOUT: "630s"' -and (Document $http 'Deployment' 'fixture-media-rest') -match 'terminationGracePeriodSeconds: 660') 'REST scale-in must allow graceful completion of bounded requests'
$httpPortal = Render -Extra ($httpArgs + @('--set','components.controlApi.image.tag=2.0.1'))
foreach ($role in @('widget','archive','rest','coordinator','provisioner','imgproxy')) {
    Assert-True ((Document $http 'Deployment' "fixture-media-$role") -eq (Document $httpPortal 'Deployment' "fixture-media-$role")) "HTTP portal-only change rolls $role"
}
$restOnly = Render -Extra ($httpArgs + @('--set','httpScaling.widget.enabled=false'))
Assert-True (([regex]::Matches($restOnly, '(?m)^kind: HTTPScaledObject$')).Count -eq 1 -and (Document $restOnly 'Deployment' 'fixture-media-widget') -match '(?m)^  replicas: 1$' -and (Document $restOnly 'Ingress' 'fixture-media-management') -notmatch 'interceptor') 'REST-only HTTP scaling failed'
$widgetOnly = Render -Extra ($httpArgs + @('--set','httpScaling.rest.enabled=false'))
Assert-True (([regex]::Matches($widgetOnly, '(?m)^kind: HTTPScaledObject$')).Count -eq 1 -and (Document $widgetOnly 'Deployment' 'fixture-media-rest') -match '(?m)^  replicas: 1$' -and (Document $widgetOnly 'ConfigMap' 'fixture-media-widget') -match 'WORKER_BASE_URL: "http://fixture-media-rest:8080"') 'Widget-only interception failed'
$disabled = Render -Extra ($httpArgs + @('--set','httpScaling.widget.enabled=false,httpScaling.rest.enabled=false'))
Assert-True ($disabled -eq $rendered) 'Disabling HTTP scaling must fully restore fixed-replica manifests'
$warm = Render -Extra ($httpArgs + @('--set','httpScaling.rest.minReplicas=2,httpScaling.rest.maxReplicas=6'))
Assert-True ((Document $warm 'HTTPScaledObject' 'fixture-media-rest') -match 'min: 2\s+max: 6') 'Warm REST bounds failed'
$httpNoArchive = Render -Extra ($httpArgs + @('--set','scaling.enabled=false,components.archive.replicas=2'))
Assert-True ($httpNoArchive -notmatch '(?m)^kind: ScaledObject$' -and ([regex]::Matches($httpNoArchive, '(?m)^kind: HTTPScaledObject$')).Count -eq 2 -and (Document $httpNoArchive 'Deployment' 'fixture-media-archive') -match '(?m)^  replicas: 2$' -and (Document $httpNoArchive 'Deployment' 'fixture-media-coordinator') -match '(?m)^  replicas: 1$') 'Archive and HTTP scaling must be independently switchable'
$renamed = Render -Extra ($httpArgs + @('--namespace','renamed-ns','--set','fullnameOverride=renamed,ingress.public.host=new-images.invalid,ingress.management.host=new-management.invalid,httpScaling.clusterDomain=internal.example,httpScaling.interceptor.port=8090,httpScaling.interceptor.podPort=9090'))
Assert-True ((Document $renamed 'ConfigMap' 'renamed-widget') -match 'http://renamed-rest-interceptor.renamed-ns.svc.internal.example:8090') 'REST URL does not follow release/namespace/domain/port'
Assert-True ((Document $renamed 'HTTPScaledObject' 'renamed-rest') -match '"renamed-rest-interceptor.renamed-ns.svc.internal.example"') 'REST Host does not match generated URL'
Assert-True ((Document $renamed 'HTTPScaledObject' 'renamed-widget') -match '"new-images.invalid"' -and (Document $renamed 'HTTPScaledObject' 'renamed-widget') -match '"new-management.invalid"') 'Widget scaling hosts are hardcoded'
Assert-True ((Document $renamed 'Ingress' 'renamed-management') -match 'number: 8090' -and (Document $renamed 'Service' 'renamed-widget-interceptor') -match 'port: 8090' -and (Document $renamed 'NetworkPolicy' 'renamed-widget') -match 'port: 9090') 'Service and pod ports must be independently respected'
$httpInvalid = @(
    @('--set','httpScaling.widget.minReplicas=0'),
    @('--set','httpScaling.widget.maxReplicas=2'),
    @('--set','httpScaling.rest.minReplicas=5'),
    @('--set','httpScaling.rest.maxReplicas=0'),
    @('--set','httpScaling.rest.targetConcurrency=0'),
    @('--set','httpScaling.rest.conditionWaitSeconds=60'),
    @('--set','httpScaling.rest.responseHeaderSeconds=600'),
    @('--set','httpScaling.rest.scaledownSeconds=0'),
    @('--set','httpScaling.interceptor.service='),
    @('--set','httpScaling.interceptor.namespace='),
    @('--set-json','httpScaling.interceptor.podLabels={}'),
    @('--set','httpScaling.interceptor.port=0'),
    @('--set','httpScaling.interceptor.podPort=65536'),
    @('--set','httpScaling.addOnVersion=0.8.0'),
    @('--set','httpScaling.addOnVersion=0.12.0'),
    @('--set','httpScaling.clusterDomain=bad_domain'),
    @('--set', ('httpScaling.clusterDomain=' + ('a' * 64) + '.example')),
    @('--set','httpScaling.rest.pathPrefixes[0]=/'),
    @('--set','ingress.public.host=fixture-media-rest-interceptor.fixture-media.svc.cluster.local'),
    @('--kube-version','1.30.0'),
    @('--kube-version','1.34.0'),
    @('--set','autoscaling.enabled=true')
)
foreach ($case in $httpInvalid) {
    $old = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $null = & helm template fixture $chart --namespace fixture-media -f $fixture @httpArgs @case 2>&1
    $code = $LASTEXITCODE
    $ErrorActionPreference = $old
    Assert-True ($code -ne 0) "Invalid HTTP scaling input accepted: $($case -join ' ')"
}
$invalid = @(
    @('components.coordinator.replicas=0'),
    @('components.rest.replicas=0'),
    @('components.widget.clientId=00000000-0000-0000-0000-000000000012'),
    @('imgproxy.clientId=00000000-0000-0000-0000-000000000011'),
    @('ingress.public.host=management.invalid'),
    @('upload.maxBytes=0'),
    @('jwt.signingSecret.name='),
    @('worker.metricsMaxAgeSeconds=5'),
    @('scaling.fallbackReplicas=99'),
    @('scaling.enabled=false'),
    @('origins.approved[0]=*'),
    @('imgproxy.image.tag=latest'),
    @('azure.controlEndpoint=https://fixturemedia.table.core.windows.net'),
    @('azure.credentialsTable=TenantDirectory'),
    @('azure.drainTable=TenantRuntime'),
    @('azure.drainTable='),
    @('oidc.audience=another-client'),
    @('components.archive.scratchBytes=1'),
    @('components.rest.scratchBytes=1'),
    @('worker.localConcurrency=0'),
    @('worker.localPerTenantConcurrency=2'),
    @('worker.maxImageOutputBytes=67108864'),
    @('worker.nativeHeapMb=32'),
    @('worker.nativeAddressSpaceBytes=603979776'),
    @('environments.AZURE_BLOB_STORAGE_CONNECTION=forbidden')
)
foreach ($case in $invalid) {
    $old = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $null = & helm template fixture $chart -f $fixture --set $case[0] 2>&1
    $code = $LASTEXITCODE
    $ErrorActionPreference = $old
    Assert-True ($code -ne 0) "Invalid input accepted: $($case[0])"
}
$old = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
$null = & helm template fixture $chart 2>&1
$code = $LASTEXITCODE
$ErrorActionPreference = $old
Assert-True ($code -ne 0) 'Unconfigured defaults must fail closed'
Write-Output "PASS: 2 strict lints; 11 successful renders; resource/auth/scaling/rollout/HTTP-routing assertions; $($invalid.Count + $httpInvalid.Count + 1) rejected invalid configurations. No cluster/cloud operations."
& (Join-Path $PSScriptRoot 'verify-bootstrap.ps1')
$global:LASTEXITCODE = 0
