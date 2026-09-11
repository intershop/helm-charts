# Multi-tenant media installation

**PRODUCTION CUTOVER BLOCKED.** This breaking chart revision is not compatible with
the former single-container values or images. One chart/release owns seven
deployments; storage-api is a library, not an eighth service. No infrastructure,
secret, tenant, blob, or migration is created by Helm.

## Configuration and rendering

Use `values.yaml` as the input inventory and `values.schema.json` as the contract.
Blank endpoints, identities, hosts, secrets, image tags and zero policy limits
intentionally fail lint/render. Supply the seven **distinct** client IDs, six
distinct table names in a separate control account, media endpoint, independent
role images, approved company OIDC settings, approved shop origins, TLS secrets,
controller pod/namespace selectors and reviewed processing/upload budgets.
Every service uses port 8080. Widget's HTTP root is always `/mediawidget`;
all other Java roles use `/`. imgproxy retains its separate `/imgproxy` prefix.
`oidc.audience` must equal `oidc.clientId` or rendering fails.

```powershell
helm version --short
helm lint . --strict -f .\tests\values.yaml
helm template fixture . --namespace fixture-media -f .\tests\values.yaml
.\tests\verify.ps1
# Environment validation, not a deployment:
helm lint . --strict -f .\reviewed-environment.yaml
helm template reviewed . --namespace <namespace> -f .\reviewed-environment.yaml
```

`tests/values.yaml` contains synthetic `.invalid` hosts/registries and dummy IDs.
It is **only an offline fixture**, never a deployable environment. No subchart
download is required; imgproxy resources are maintained locally to ensure secret,
identity and networking constraints have one owner. KEDA CRDs/operator and the
Azure workload identity webhook are external platform prerequisites; Helm rendering
does not verify their presence. No tool installs/upgrades are needed when Helm exists.

## Roles and application contracts

| Values key / deployment suffix | Mode and exposure |
|---|---|
| `components.widget` / `widget` | Shop-authenticated management; anonymous tenant image URL resolver |
| `components.archive` / `archive` | `MEDIA_ROLE=archive`, KEDA-scaled, no Service or ingress |
| `components.rest` / `rest` | `MEDIA_ROLE=rest`, fixed positive replicas by default; optional private HTTP scaling, **no archive polling** |
| `components.coordinator` / `coordinator` | `MEDIA_ROLE=coordinator`, exactly one always-on replica; KEDA-only ingress |
| `components.controlApi` / `control-api` | `CONTROL_ROLE=api`, company OIDC web-app portal/API, no media administration |
| `components.provisioner` / `provisioner` | `CONTROL_ROLE=provisioner`, provisioner profile, no Service/ingress |
| `imgproxy` / `imgproxy` | v3.30.0, signed sources, separate images-only workload identity |

The shared projection settings are `TENANCY_CONTROL_ENDPOINT`,
`TENANCY_DIRECTORY_TABLE`; only widget gets `TENANCY_CREDENTIALS_TABLE`.
Worker runtime configuration maps to `MEDIA_CONCURRENCY`,
`MEDIA_PER_TENANT_CONCURRENCY`, `MEDIA_TENANTS_PER_POLL`, `MEDIA_JOBS_PER_TENANT`,
`MEDIA_MAX_ARCHIVE_BYTES`, `MEDIA_MAX_IMAGE_BYTES`, `MEDIA_MAX_IMAGE_DIMENSION`,
`MEDIA_MAX_ENTRIES`, `MEDIA_MAX_EXPANDED_BYTES`, `MEDIA_MAX_IMAGE_PIXELS`,
`MEDIA_MAX_PROCESSING_SECONDS`, `MEDIA_METRICS_FRESHNESS_SECONDS`,
`MEDIA_RETENTION_HOURS`, and `MEDIA_COORDINATOR_INTERVAL`.
Worker local concurrency and native-child limits are also explicit:
`MEDIA_LOCAL_CONCURRENCY`, `MEDIA_LOCAL_PER_TENANT_CONCURRENCY`,
`MEDIA_MAX_IMAGE_OUTPUT_BYTES`, `MEDIA_NATIVE_HEAP_MB`,
and `MEDIA_NATIVE_ADDRESS_SPACE_BYTES`.
`ARCHIVE_PROCESSING_INTERVAL` applies only when application role is archive.
Do not infer safety from an unused polling property; the application role guard
must pass the no-polling REST test.

Widget allocation/finalization uses authenticated
`POST /mediawidget/api/tenants/{tenantId}/uploads` and `.../{jobId}/finalize` with bounded
`TENANCY_MAX_UPLOAD_BYTES`, `TENANCY_MAX_OUTSTANDING_UPLOADS` and
`TENANCY_UPLOAD_GRANT_SECONDS`. Browser SAS URLs must not appear in access logs.
The widget's worker-client URL is generated from the release's REST Service
(or its private interceptor alias when HTTP scaling is enabled).
RS256 tokens use `TENANCY_WORKER_TOKEN_ISSUER`, `...AUDIENCE`, `...KEY_ID`,
tenant UUID, `scope=resize`, `kid`, and maximum 60-second expiry. The signing key
is mounted only on widget, verification key only on REST. Verification supports
a mounted PEM/JWKS file; rotate the verifier before the signer.

The control plane uses `CONTROL_REGISTRY_ENDPOINT`, table mappings,
`CONTROL_MEDIA_ENDPOINT`, `CONTROL_CREDENTIAL_REFERENCE`, `CONTROL_INSTALLATION_ID`
and explicit bounded policies. `azure.drainTable` maps only to coordinator's
`TENANCY_DRAIN_TABLE` and provisioner's `CONTROL_DRAIN_TABLE`. TenantDrain grants
coordinator sole contributor access and provisioner read-only access; widget,
archive and REST have none. All four data-plane Java roles can write TenantRuntime
for their bounded cluster/admission/usage reservations, not drain evidence.

Provisioner keeps `127.0.0.1`, deny-all application HTTP and a GET-only local health
exception. With no Service/ingress it uses exec probes:
`java -cp /app/app/* com.intershop.cdn.controlplane.HealthProbe`.
The application image must include this JDK-only class. Other Java roles use HTTP
probes; widget uses `/mediawidget/q/health/live` and `/mediawidget/q/health/ready`,
others `/q/health/live` and `/q/health/ready`. No probe invokes business operations.

Every read-only-root Java pod mounts disk-backed, size-bounded `/media-runtime` emptyDir,
sets `JAVA_TOOL_OPTIONS=-Djava.io.tmpdir=/media-runtime` and
`QUARKUS_HTTP_BODY_UPLOADS_DIRECTORY=/media-runtime/uploads`; imgproxy uses
`TMPDIR=/media-runtime`. Scratch must never overlay the widget/worker application's
`/work` directory (including widget `/work/start.sh` and `/work/quarkus-run.jar`),
control-plane `/app`, or native helper `/opt/native-child`. Image entrypoints,
including worker `tini -s`, are preserved.
No scratch uses `/tmp` or memory-backed emptyDir. Per-role `scratchBytes` and
ephemeral-storage requests/limits are explicit. Archive scratch must cover
`maxConcurrentJobs * (upload.maxBytes + maxExpandedBytes)`; widget/REST scratch
must cover concurrent bounded request bodies. Set ephemeral-storage limits above
scratch capacity plus writable logs and request enough node disk to schedule it.
These are disk floors, **not a memory safety proof**: budget JVM heap/native buffers,
JSON/base64 and decoded/transformed pixels (at least four bytes per pixel per
buffer) times concurrent jobs plus HTTP threads, and reserve headroom for the
provisioner's short-lived probe JVM. Review per-pod concurrency, queueing and
container memory limits with representative worst-case inputs before deployment.

Worker images using the isolated native-processing runtime additionally require
**Linux JVM execution (not native-image)** and `bubblewrap` packaged in the image.
The cluster must permit the runtime's unprivileged user, PID and network namespaces.
Node sysctls, seccomp and AppArmor/SELinux or other LSM policy can deny these even
when the executable is present; verify sandbox startup with the exact image and
pod security configuration before enabling processing. Namespace/sandbox failures
must fail closed. Do **not** automatically add privileged mode, capabilities,
unconfined profiles or writable mounts to make the sandbox start. If the reviewed
cluster policy cannot support it, keep processing disabled until an approved
runtime/platform solution exists.
The worker runtime's local Docker smoke test has already observed namespace denial
under default Docker seccomp with a non-root/read-only container. This is not proof
that Kubernetes `RuntimeDefault` will permit the sandbox on a particular node.
This chart keeps its existing `RuntimeDefault` profile; any node/profile adaptation
requires separate platform review, not an automatic security relaxation.

The isolated child uses bounded pipes and a read-only sandbox; no additional
writable volume is required. Budget container memory for the parent JVM **plus up
to `MEDIA_LOCAL_CONCURRENCY` concurrent child JVMs**, including each child's heap,
native decoding buffers and process overhead. Existing parent heap or scratch
limits alone do not bound aggregate RSS. Supply reviewed `worker.localConcurrency`,
`localPerTenantConcurrency` and `maxImageOutputBytes`. The output limit must not
exceed `maxImageBytes`: the worker's 64 MiB output default would otherwise prevent
startup for the chart's 25 MiB synthetic input fixture. `worker.nativeHeapMb`
defaults to 256; `nativeAddressSpaceBytes` defaults to 2147483648 and must cover
the heap plus 512 MiB. The latter bounds **virtual address space**, not reserved
or guaranteed resident memory.

The packaged worker image supplies `MEDIA_NATIVE_CHILD_DIRECTORY=/opt/native-child`
and parent `JAVA_OPTS=-Xms64m -Xmx512m`; the chart does not overwrite those image
settings. Preserve the image's **`tini -s` subreaper entrypoint** (or an independently
verified equivalent); do not replace it with bare Java as PID 1. Killing a timed-out
sandbox does not by itself reap orphaned native descendants. This chart deliberately
does not set container `command`/`args` overrides for worker roles.
Validate the actual released artifact and aggregate parent/child/native
RSS against explicitly reviewed pod requests/limits. In particular, a 1 GiB REST
limit is **not certified sufficient** for a 512 MiB parent plus multiple 256 MiB
child heaps and native buffers. Do not raise local concurrency merely because the
global processing budget or HTTP replica ceiling is higher.

Each role has its own ConfigMap and config/identity checksums. Image-only portal
updates do not change any data-plane pod template. Changing a genuinely shared
directory endpoint intentionally affects its readers. External secret content
changes require a targeted `rolloutRevision` bump; secret values are never
looked up or hashed by Helm. Release fullname/namespace changes require new
federated subjects and must not be treated as a routine rename.

## Routing, auth, networking and scaling

Three **distinct** TLS hosts are required:

* Public: only `/mediawidget/public/tenants/` (widget resolver) and `/imgproxy/` (signed images).
  Widget public base is `https://<public-host>/mediawidget`, not the host root.
  There is no arbitrary source gateway or tenant-less image fallback.
* Management: `/mediawidget`, preserved by shop backend proxies (no prefix rewrite).
  Application credential verification
  protects API, Vaadin bootstrap/UIDL, push, heartbeat and reconnect. Browsers use
  the shop's same-origin proxy; shop backends strip/replace Authorization and
  X-Tenant-ID, enforce user permissions, and preserve CSRF/WebSocket handling.
* Control: `/`, application OIDC authenticates company owners/operators.
  An ingress hostname or network label is **not** authentication.

Ingress annotations are controller-specific operator inputs. Configure HTTPS
redirect, no management/auth caching, correct client/proxy header trust and
WebSocket timeouts. For multiple widget replicas require session affinity or a
validated shared-session strategy for Vaadin. Test `/mediawidget/q/health` access deliberately;
health probes are unauthenticated while management/business routes remain protected.

NetworkPolicies constrain both ingress **and** egress. Fixed REST accepts only the same
release's widget; HTTP-scaled REST accepts only the configured interceptor namespace
**and** pod labels. Coordinator accepts only explicit KEDA namespace **and** pod
labels. Archive/provisioner have no ingress. Ingress controller namespace+pod
selectors reach widget/control/imgproxy. DNS selectors are explicit; public
HTTPS egress excludes private networks, loopback and IMDS. This is not FQDN
egress enforcement; use a reviewed egress gateway/firewall if required. A CNI
that actually enforces NetworkPolicy is mandatory. Host-network or node-local DNS
installations require reviewed adaptation, not removal of network isolation.

By default only archive processing scales to zero, while widget and REST use
their configured positive `components.<role>.replicas`. Archive `scaling` is
independent of the optional `httpScaling` described below. KEDA `metrics-api` reads
`http://<release>-coordinator.<namespace>.svc:8080/internal/backlog`,
`valueLocation=metricValue`, AverageValue:

```json
{"metricName":"media_backlog","metricValue":3,"pendingJobs":2,"runningJobs":1,"observedAt":"<ISO instant>"}
```

The field names/count semantics, not example metricName, are the contract.
Only registered runnable/active work counts; logs/uncommitted uploads/failures do
not. Startup, stale snapshots, directory/storage errors must return non-2xx
(503), **never successful zero**. Freshness is enforced by the application using
`MEDIA_METRICS_FRESHNESS_SECONDS` (at least twice scan interval), not by JSON
timestamp support in KEDA. Metrics are `no-store`. Fallback replicas are positive
after bounded failures; cooldown and HPA scale-down stabilization are explicit.
Prove actual scale-from-zero and KEDA failure/fallback behavior on the installed
KEDA version: lint/render cannot prove it, and fallback is not a substitute for
alerting when activation is unavailable.

### Optional HTTP add-on: routing, compatibility and session safety

`httpScaling.widget.enabled` and `httpScaling.rest.enabled` independently opt in
to **pre-installed** HTTP add-on infrastructure. Defaults are false: no
HTTPScaledObject, interceptor alias, or HTTP infrastructure dependency is emitted.
The chart never installs CRDs/operators, changes their configuration/policies, or
discovers their versions from a live cluster.

The supported API is **HTTP add-on 0.11.1**, `http.keda.sh/v1alpha1`, with
`scaleTargetRef.name/kind/apiVersion/service/port`, `scalingMetric.concurrency`,
and per-object `timeouts`. `httpScaling.addOnVersion` is a declaration, not an
installation/version check. Other declared versions are rejected instead of
silently rendering obsolete `deployment`/`targetPendingRequests` fields.
The [versioned compatibility table](https://github.com/kedacore/http-add-on/blob/v0.11.1/docs/install.md)
lists **KEDA 2.18 and Kubernetes 1.31–1.33**; the optional path checks that Kubernetes
range (use `--kube-version` for offline renders). Upgrade other versions only after
separate schema/controller/traffic verification. The upstream release is **beta**;
this chart does not make it production-ready.
[Pinned CRD](https://github.com/kedacore/http-add-on/blob/v0.11.1/config/crd/bases/http.keda.sh_httpscaledobjects.yaml)
and [HTTPScaledObject reference](https://github.com/kedacore/http-add-on/blob/v0.11.1/docs/ref/v0.11.0/http_scaled_object.md)
are the source contract, not a claim of live cluster testing.

Supply reviewed `httpScaling.interceptor.namespace`, `service`, `port` (Service
port), `podPort` (actual listener for NetworkPolicy), and nonempty `podLabels`.
`clusterDomain` defaults to `cluster.local`. The operator/scaler/interceptor must
watch this release namespace, with matching KEDA watch scope. Synthetic example:

```powershell
helm lint . --strict -f .\tests\values.yaml -f .\tests\http-scaling.yaml --kube-version 1.32.0
helm template fixture . --namespace fixture-media -f .\tests\values.yaml -f .\tests\http-scaling.yaml --kube-version 1.32.0
```

Traffic paths:

* **Widget enabled:** existing public resolver and management ingress paths target
  `<fullname>-widget-interceptor`, a same-namespace ExternalName alias to the
  configured interceptor. Its HTTPScaledObject matches the two **generated ingress
  hosts** and `/mediawidget`, forwarding to the unchanged widget backend Service.
  imgproxy and control routes bypass it. Public ingress still exposes **only**
  `/mediawidget/public/tenants/` and `/imgproxy/`, not management/resize/metrics.
* **REST enabled:** both widget worker-client settings use
  `http://<fullname>-rest-interceptor.<namespace>.svc.<clusterDomain>:<port>`.
  DNS resolves this alias to the interceptor, while HTTP Host retains the alias;
  the REST HTTPScaledObject matches that exact generated host and `/api/tenants/`.
  Its upstream remains `<fullname>-rest:8080`, never the alias (no routing loop).
  There is **no public REST ingress**, and no metrics/health prefix in its HTTP route.
* Enabled backends accept only interceptor pods. Widget egress uses the interceptor
  listener instead of direct REST when REST scaling is enabled. Backend Services
  remain ClusterIP and kubelet probes remain direct, not scaling traffic.
  JWT signatures, audience/issuer/tenant/scope validation, mounted key separation
  and application roles are unchanged; **a matching Host is never authentication**.

The ingress controller must support **ExternalName backends** and preserve the
original Host/path/Authorization, WebSocket upgrades and appropriate trusted
forwarding headers. Do not rewrite Host to the interceptor's Service name, forward
untrusted Host overrides, or expose its catch-all listener/REST alias publicly.
Restrict the **external interceptor's** ingress to the reviewed ingress controller
and widget peers, and egress to the application backends/DNS/control endpoints
needed by that add-on. Complementary ingress-controller egress and add-on
NetworkPolicies are the platform operator's responsibility: this chart does not
broaden or overwrite resources in another release/namespace. Kubernetes policy
does not filter HTTP hosts or authenticate users; the interceptor is a trusted
proxy. Test hostile Host/forwarding headers and public-path isolation end to end.

**Vaadin is deliberately pinned to one replica (`minReplicas=maxReplicas=1`).**
The widget HTTPScaledObject restores HTTP routing/metrics and scaler ownership,
but **does not provide widget horizontal elasticity or scale-to-zero**. Zero or
multiple intercepted widget replicas are rejected. Active UI sessions can be idle
between requests; concurrency/cooldown is not an active-session signal. Ingress
cookie affinity to an interceptor does not ensure affinity to a backend Vaadin
pod. Widget uses `Recreate` in this mode to avoid a transient second backend during
rollout; upgrades/pod failure still invalidate in-memory sessions and require
maintenance/reconnect planning. True UI elasticity requires independently proven
end-to-end session routing, shared state or session-aware drain—not a larger HPA.
The existing fixed-replica option remains available unchanged; multi-replica
fixed installations still require their own validated session strategy.

**REST supports configured `minReplicas` (including zero) through `maxReplicas`.**
`targetConcurrency` measures intercepted in-flight requests, not tenant counts.
Use positive `minReplicas` if cold-start latency cannot fit the client/JWT budget.
`conditionWaitSeconds` is capped at 30 (default 20) to leave room within the
60-second worker JWT lifetime. This cannot guarantee token validity after upload,
queueing and startup; a slow cold start can fail or produce 401. Never extend JWT
lifetimes or blindly retry non-idempotent resize writes to mask that failure.
Measure token age/startup first, and retain a warm replica if necessary.
`responseHeaderSeconds` must exceed `worker.maxProcessingSeconds`; align widget
client, ingress and interceptor global request timeouts/body limits independently.
Only per-object condition-wait/response-header timeouts are set here.
REST graceful shutdown uses that response-header budget, with Kubernetes termination
grace 30 seconds longer. This helps finish bounded in-flight requests during scale-in;
it is not proof against forced deletion, lost connections or hung native/storage work.

Each enabled Deployment omits `spec.replicas`; **only the HTTP add-on** creates and
owns its ScaledObject/HPA. Do not attach another HPA/ScaledObject or manually edit
the generated objects. `scaledownSeconds` controls HTTP scale-to-zero cooldown,
not session-aware scale-in or a custom HPA behavior/fallback. Archive's explicit
fallback/stabilization does **not** apply to HTTP objects; alert on add-on/metrics
failure and use a warm minimum for required availability. When disabling HTTP
scaling, positive `components.<role>.replicas` become authoritative again and direct
routes/policies return. Drain traffic for this transition, verify deletion of the
old add-on-owned ScaledObject/HPA, and verify positive ready endpoints before
resuming traffic; a single Helm upgrade is not an atomic routing/scaler handoff.

**Required live acceptance:** verify installed CRD/controller compatibility,
ExternalName resolution and Host preservation, public-path and invalid-JWT denial,
policy-enforced interceptor-only backends, cold REST 0→1 with a fresh valid token,
concurrent resize completion during scale-in, idle zero/cooldown and scaler failure,
Vaadin bootstrap/UIDL/upload/heartbeat/push/reconnect (including idle sessions),
and rollback to fixed replicas. No such cluster proof is claimed by local renders.

## imgproxy 3.30 evidence and restrictions

Source inspection, **not an image runtime test**, verified:

* [v3.30.0 Azure adapter](https://github.com/imgproxy/imgproxy/blob/v3.30.0/transport/azure/azure.go):
  no `IMGPROXY_ABS_KEY` invokes `azidentity.NewDefaultAzureCredential`.
* [v3.30.0 go.mod](https://github.com/imgproxy/imgproxy/blob/v3.30.0/go.mod):
  Azure identity dependency is **v1.12.0**.
* [that exact Azure SDK implementation](https://github.com/Azure/azure-sdk-for-go/blob/sdk/azidentity/v1.12.0/sdk/azidentity/default_azure_credential.go):
  supports WorkloadIdentityCredential and `AZURE_TOKEN_CREDENTIALS` selecting it alone.
* [v3.30.0 configuration](https://github.com/imgproxy/imgproxy/blob/v3.30.0/config/config.go)
  and [pattern converter](https://github.com/imgproxy/imgproxy/blob/v3.30.0/config/configurators/configurators.go):
  signing key/salt, 32-byte signature, ABS endpoint, allowed sources and source
  address restrictions exist. Wildcards match no slash, patterns are prefix-anchored.
* [versioned Azure documentation](https://docs.imgproxy.net/3.30.x/image_sources/azure_blob_storage)
  confirms ABS and identity support; newer documentation was not used to assume it.

The chart therefore explicitly selects `WorkloadIdentityCredential`, preventing
fallback to node identity. It permits only `abs://t-*-images/` source prefixes,
pins one trusted media account endpoint, sets no Azure key/client secret, and
requires images-only container RBAC. Widget constructs and signs the resolved
images target server-side; arbitrary unsigned/tampered sources must fail.
No `insecure`/trusted-signature bypass is configured. Source redirects are disabled.
No upload, control Table, unconditioned account-wide data role, local-file source or IMDS access
is granted to imgproxy. Dedicated-account routing is not supported by this release.
Pin/attest the deployed v3.30.0 artifact in your registry policy and validate its
actual behavior before release; source inspection cannot attest a downloaded image.

See [Azure bootstrap](docs/AZURE-BOOTSTRAP.md) for scoped RBAC, browser CORS,
operator proof gates, retention and cache policy.
See [cutover gates](docs/CUTOVER.md) for required runtime evidence.

## Verification performed

With existing Helm **v3.18.5**, `tests/verify.ps1` passed:

* `helm lint <chart> --strict -f <chart>\tests\values.yaml`.
* `helm template fixture <chart> --namespace fixture-media -f <fixture>`.
* The same render with `--set components.controlApi.image.tag=2.0.1
  --set oidc.issuer=https://identity.invalid/updated-company`; every other
  Deployment remains byte-for-byte identical.
* The same render with `--set scaling.enabled=false
  --set components.archive.replicas=2`; no ScaledObject remains.
* HTTP overlay lint and eight additional renders (both roles, each role alone,
  portal-only update, disabled roundtrip, warm REST bounds, independent archive
  switch, renamed hosts/namespace/cluster domain and different Service/pod ports):
  **two strict lints, eleven renders**.
* Resource counts, role/auth/source/probe/network/metric/HTTP-ownership and shutdown
  assertions and **48 negative configurations**, including empty defaults, invalid
  HTTP versions/bounds/selectors/ports/hosts/paths, unsafe widget replicas and native
  worker concurrency/output/address-space startup contracts.

* Offline bootstrap fixture validation and exact role/ABAC/grant assertions,
  future-container pattern coverage, deterministic assignments, drain/proof
  isolation and three rejected bootstrap fixtures. Bootstrap ran in default
  **dry-run only**, with an Azure-command trap.

`git diff --check` passed. No tool was installed. No cluster,
Azure, OIDC provider, browser, actual container image, RBAC/SAS, data migration or
runtime scaling proof was run. Application env/route contracts were checked
against the revised integration contract; final artifact verification is
still mandatory. Automatic future-container pool assignments are implemented;
activation still requires independently verified operator pool attestation or
existing per-tenant proofs. No real access/isolation/CORS proof was fabricated.

### Offline packaged-runtime mount regression

`tests/verify-runtime-mount.ps1` is an optional Docker check requiring three
explicit, already-local images; it never pulls or deploys them:

```powershell
.\tests\verify-runtime-mount.ps1 -WidgetImage <local-widget-image> -WorkerImage <local-worker-image> -ControlPlaneImage <local-control-image>
```

It derives scratch mounts and Java/upload settings from the rendered chart, checks
that application JARs/launchers remain readable, writes only the project-local
scratch bind mount, and exercises each original image entrypoint. Containers use
UID/GID 1000, read-only root, no network, no added capabilities, and
no-new-privileges; worker `tini -s` is required. Negative controls reproduce hiding
each JAR with the former application-directory overlay. Containers and scratch
files are cleaned in `finally` blocks.

Three positive mount/launcher probes and three negative overlay controls passed
locally. Worker used its built image; widget/control probes used their Dockerfile
application layouts and current packages on the cached worker JRE22 image to avoid
network pulls. Those substituted-base images are **layout checks, not attestations
of the production widget/control base images**. Bootstrap reached application
initialization; missing production configuration is expected to fail closed.
This is not a healthy-service/cloud test and does not prove Kubernetes emptyDir
size enforcement, fsGroup behavior, target-node seccomp or native sandbox operation.
