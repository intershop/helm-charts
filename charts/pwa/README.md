# Intershop PWA Helm Chart

Installs the [Intershop PWA](https://github.com/intershop/intershop-pwa) in a Kubernetes cluster environment.

## Installation

```bash
$ helm repo add intershop https://intershop.github.io/helm-charts
$ helm repo update
$ helm install my-release intershop/pwa
```

## Compatibility

| Requirement | Supported  | Additional information                                                                                                                                                                                                                                                                                                                                 |
| ----------- | ---------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Kubernetes  | `>= 1.23`  | The chart uses the `autoscaling/v2` HorizontalPodAutoscaler API, which is GA from Kubernetes 1.23. The range is enforced via the `kubeVersion` field in _Chart.yaml_, so `helm install`/`upgrade` fails fast with older clusters. All other resources use stable APIs (`apps/v1`, `networking.k8s.io/v1`, `batch/v1`, `rbac.authorization.k8s.io/v1`). |
| Helm CLI    | `>= 4.0.0` | The chart and its CI pipeline target Helm 4. CI validates the chart against the current stable Helm 4 release on every change.                                                                                                                                                                                                                         |

## Release Versions

### 1.0.0

First major release — the chart has been **renamed from `pwa-main` to `pwa`** and restructured into explicit **`app`** (Angular SSR) and **`proxy`** (nginx) tiers.
See [Why Upgrade to PWA Helm Chart 1.0.0](https://github.com/intershop/helm-charts/blob/main/charts/pwa/docs/why-upgrade-to-1.0.0.md) for the benefits of the new chart version.
Read the [Migration to 1.0.0](https://github.com/intershop/helm-charts/blob/main/charts/pwa/docs/migrate-to-1.0.0.md) guide before upgrading.

**Breaking**

- **Chart renamed from `pwa-main` to `pwa`.**
  Update your Helm reference (`intershop/pwa-main` to `intershop/pwa`) and, for Flux, `spec.chart.spec.chart: pwa-main` to `pwa`.
  Release tags change from `pwa-main-X.Y.Z` to `pwa-X.Y.Z`.
- Values restructured: Top-level SSR config to `app.*`; `cache.*` to `proxy.*`
- `upstream.icmBaseURL` changed to `config.icmBaseUrl`.
  Now **required** (no dev default; install fails fast if unset).
- Resource names `*-pwa-main` / `*-pwa-cache` changed to `*-pwa-app` / `*-pwa-proxy`.
  Update anything that selects them by name (dashboards, `NetworkPolicy`, scripts).

**Removed**

- Shared Redis cache integration for the nginx tier (the Redis flush job and `REDIS_URI` configuration)
- `upstream.cdnPrefixURL`, the prefetch job (`cache.prefetch`), and the internal `calculated` section

**Added**

- Configurable per-tier `updateStrategy`, a `helm test` connection hook, and helm-unittest suites

**Changed**

- Secure-by-default: Non-root, dropped Linux capabilities, no service-account token automount
- Production defaults: Two replicas per tier, resource requests/limits, liveness/readiness/startup probes
- Image tags default to `release-<chart appVersion>` (was `latest`); pull policy `IfNotPresent` (was `Always`)
- Requires **Helm 4** and **Kubernetes 1.23+**

---

### Pre-1.0.0 Releases

<details>
<summary>
The following table (click to display) provides an overview of the different Pre-1.0.0 release versions and the minimum required PWA version to use it with.
In addition, the version changes and necessary migration information are provided.
</summary>

| Chart  | PWA    | Changes                                                                                                                                                                                                                                                                                                                                                                                                                                 | Migration Information                                                                                                                                                                                                                                                                       |
| ------ | ------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 0.13.0 | 1.0.0  | <ul><li>Introduced Pod anti-affinity configuration (enabled by default with soft rules)</li></ul>                                                                                                                                                                                                                                                                                                                                       | See [Migration to 0.13.0](https://github.com/intershop/helm-charts/blob/main/charts/pwa/docs/migrate-to-0.13.0.md) if you have custom `podAntiAffinity` rules in your `affinity` configuration                                                                                              |
| 0.12.0 | 1.0.0  | <ul><li>Cache reset enabled by default</li><li>Changed structure of cache reset image configuration</li><li>Removed cache init container</li></ul>                                                                                                                                                                                                                                                                                      | See [Migration to 0.12.0](https://github.com/intershop/helm-charts/blob/main/charts/pwa/docs/migrate-to-0.12.0.md)                                                                                                                                                                          |
| 0.11.0 | 1.0.0  | <ul><li>Added option to enable/disable cache init container</li><li>Introduced cache container reset after deployment via hook job</li><li>Provided option to change the `redis-cli` image for the cache flush job</li><li>Introduced options for explicit deployment labels and deployment annotations</li></ul>                                                                                                                       |                                                                                                                                                                                                                                                                                             |
| 0.10.0 | 1.0.0  | <ul><li>Changed Hybrid Approach handling and configuration options</li><li>Remove dependency to ICM deployment charts</li></ul>                                                                                                                                                                                                                                                                                                         | Removed unused deployment handling introduced with version 0.4.0; new configuration options require PWA 9.1.0                                                                                                                                                                               |
| 0.9.3  | 1.0.0  | <ul><li>Fixed `cache.additionalHeaders` functionality introduced with version 0.8.0</li></ul>                                                                                                                                                                                                                                                                                                                                           |                                                                                                                                                                                                                                                                                             |
| 0.9.2  | 1.0.0  | <ul><li>Fixed options to configure `successfulJobsHistoryLimit` and `failedJobsHistoryLimit` for the prefetch job</li></ul>                                                                                                                                                                                                                                                                                                             |                                                                                                                                                                                                                                                                                             |
| 0.9.1  | 1.0.0  | <ul><li>Init container image needs to be configurable</li></ul>                                                                                                                                                                                                                                                                                                                                                                         |                                                                                                                                                                                                                                                                                             |
| 0.9.0  | 1.0.0  | <ul><li>Options to configure `successfulJobsHistoryLimit` and `failedJobsHistoryLimit` for the prefetch job</li><li>Made prefetch job `args` and `image` configurable</li><li>Provided validation support for Flux configurations</li></ul>                                                                                                                                                                                             |                                                                                                                                                                                                                                                                                             |
| 0.8.0  | 1.0.0  | <ul><li>New format of declaring (multiple) Ingresses (Split Ingress)</li><li>Shared Redis cache for the nginx containers (requires PWA 5.0.0)</li><li>Additional result headers configuration (requires PWA 5.0.0)</li><li>Monitoring support with Prometheus and Grafana (for development and testing)</li><li>Delay nginx until PWA SSR is listening</li><li>Configurable update strategy</li><li>Less verbose prefetch job</li></ul> | See [Migration to 0.8.0](https://github.com/intershop/helm-charts/blob/main/charts/pwa/docs/migrate-to-0.8.0.md) regarding the new format of configuring Ingress and the dropped support of older Kubernetes clusters<br/>Configurable `updateStrategy` stays at `RollingUpdate` by default |
| 0.7.0  | 1.0.0  | <ul><li>Re-enabled support for _multi-channel.yaml_ and _caching-ignore-params.yaml_ source code fallbacks</li><li>Added additional Ingress for domain whitelisting</li><li>Added labels on deployment and Pod levels</li></ul>                                                                                                                                                                                                         | Removed deprecated configuration options:<ul><li>`upstream.icm`</li><li>`cache.enabled` - was not optional</li><li>`cache.channels`</li></ul>See [Migration to 0.7.0](https://github.com/intershop/helm-charts/blob/main/charts/pwa/docs/migrate-to-0.7.0.md)                               |
| 0.6.0  | 1.0.0  | Support for Prometheus metrics                                                                                                                                                                                                                                                                                                                                                                                                          |                                                                                                                                                                                                                                                                                             |
| 0.5.0  | 1.0.0  | Added prefetch job that can heat up caches                                                                                                                                                                                                                                                                                                                                                                                              |                                                                                                                                                                                                                                                                                             |
| 0.4.0  | 1.0.0  | Support for PWA Hybrid Approach deployment (with ICM 11)                                                                                                                                                                                                                                                                                                                                                                                | Requires PWA 3.2.0 for Hybrid Approach support                                                                                                                                                                                                                                              |
| 0.3.0  | 1.0.0  | Use of new Ingress controller definition                                                                                                                                                                                                                                                                                                                                                                                                | See [Migration to 0.3.0](https://github.com/intershop/helm-charts/blob/main/charts/pwa/docs/migrate-to-0.3.0.md)                                                                                                                                                                            |
| 0.2.4  | 0.25.0 | Support for `multiChannel`, `cacheIgnoreParams`, and `extraEnvVars` for nginx/cache deployment                                                                                                                                                                                                                                                                                                                                          | Missing support for _multi-channel.yaml_ and _caching-ignore-params.yaml_ source code fallbacks                                                                                                                                                                                             |
| 0.2.3  | 0.25.0 | Legacy Helm Chart 0.2.3 as initial version                                                                                                                                                                                                                                                                                                                                                                                              |                                                                                                                                                                                                                                                                                             |

</details>

## Parameters

The table below is generated from [_values.yaml_](./values.yaml) with [helm-docs](https://github.com/norwoodj/helm-docs).
Every configurable value is listed with its type, default, and description.
Values shown as `see values.yaml` are objects documented inline in that file.
The only value you must set is `config.icmBaseUrl` (the ICM backend URL).
Everything else ships with a production-ready default.

To regenerate the table, run `helm-docs --chart-search-root=charts/pwa --sort-values-order=file` after changing the _values.yaml_.
Changes to the _README.md.gotmpl_ also require a manual regeneration.
_README.md_ is no longer edited directly.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| nameOverride | string | `""` | Override the chart name used in resource names. |
| fullnameOverride | string | `""` | Override the fully qualified release name. |
| config.icmBaseUrl | string | `""` | Base URL of the Intershop Commerce Management (ICM) backend. Required; intentionally empty so installs must set a real backend and fail fast rather than defaulting to a dev URL. |
| config.icmBaseUrlSsr | string | `nil` | Internal Kubernetes URL of the ICM Web Adapter used by SSR or Hybrid Approach. Optional; leave unset to skip the ICM_BASE_URL_SSR env var. e.g. "http://icm-<cstmr-id>-<env>-icm-web-wa.icm-<cstmr-id>-<env>.svc.cluster.local:8080" |
| config.allowedHosts | string | `nil` | Comma-separated ALLOWED_HOSTS for the SSR app. Optional; leave unset to skip the ALLOWED_HOSTS env var. e.g. "shop.example.com,*.example.com" |
| hybrid.enabled | bool | `false` | Enable the PWA Hybrid Approach deployment. |
| hybrid.pwaExternalPort | int | `nil` | External PWA port forwarded to Responsive Starter Store requests. Optional; defaults to the standard port when unset. e.g. 443 |
| imagePullSecrets | list | `[]` | Image pull secrets applied to both tiers' pods. |
| serviceAccount.create | bool | `true` | Create a ServiceAccount, Role, and RoleBinding. Limit access to `get` on the PWA app Endpoints resource. |
| serviceAccount.automount | bool | `true` | Mount the Kubernetes API token in Pods. The proxy cache clearer uses it to read the app Endpoints resource. |
| serviceAccount.name | string | `""` | Name of the ServiceAccount to use. Generated if empty and create=true. |
| serviceAccount.annotations | object | `{}` | Annotations to add to the ServiceAccount. |
| securityContext | object | see [values.yaml](./values.yaml) | Container security context shared by both tiers (secure baseline: drop all caps, no privilege escalation). |
| app.image.repository | string | `"intershophub/intershop-pwa-ssr"` | SSR container image repository. |
| app.image.tag | string | `""` | Image tag. Defaults to `release-<chart appVersion>` when empty. |
| app.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. |
| app.replicaCount | int | `2` | Number of app replicas (ignored when autoscaling.enabled=true). |
| app.updateStrategy | string | `"RollingUpdate"` | Deployment update strategy: RollingUpdate or Recreate. |
| app.service.type | string | `"ClusterIP"` | Kubernetes Service type for the SSR service. |
| app.service.port | int | `4200` | Service port that the proxy talks to (the SSR process always listens on container port 4200). |
| app.env | list | `[]` | Extra environment variables for the SSR container. |
| app.logging.level | string | `"error"` | SSR log verbosity. |
| app.logging.format | string | `"json"` | SSR log output format. |
| app.metrics.enabled | bool | `false` | Expose Prometheus metrics of the SSR container (fixed port 9113). |
| app.metrics.detailLevel | string | `"DEFAULT"` | SSR metrics detail level. DETAILED adds request-path and REST-client metrics with higher cardinality. |
| app.podSecurityContext | object | see [values.yaml](./values.yaml) | Pod security context for the app (runs as unprivileged user 65534). |
| app.securityContext | object | `{}` | Container security context for the app, deep-merged onto the shared `securityContext` baseline (per-key overrides win). |
| app.resources | object | see [values.yaml](./values.yaml) | Resource requests/limits for the SSR container. |
| app.startupProbe | object | see [values.yaml](./values.yaml) | Startup probe for the SSR container (PM2 readiness). |
| app.livenessProbe | object | see [values.yaml](./values.yaml) | Liveness probe for the SSR container (PM2 process health, not ICM). |
| app.readinessProbe | object | see [values.yaml](./values.yaml) | Readiness probe for the SSR container (PM2 process health, not ICM). |
| app.autoscaling | object | see [values.yaml](./values.yaml) | HorizontalPodAutoscaler for the SSR tier. |
| app.nodeSelector | object | `{}` | Node selector for SSR pods. |
| app.tolerations | list | `[]` | Tolerations for SSR pods. |
| app.affinity | object | `{}` | Node/pod affinity for SSR pods (merged with podAntiAffinity). |
| app.podAntiAffinity | object | see [values.yaml](./values.yaml) | Pod anti-affinity to spread SSR replicas across nodes. |
| app.podAnnotations | object | `{}` | Extra annotations for SSR pods. |
| app.podLabels | object | `{}` | Extra labels for SSR pods. |
| app.deploymentAnnotations | object | `{}` | Extra annotations for the SSR Deployment. |
| app.deploymentLabels | object | `{}` | Extra labels for the SSR Deployment. |
| proxy.image.repository | string | `"intershophub/intershop-pwa-nginx"` | Proxy container image repository. |
| proxy.image.tag | string | `""` | Image tag. Defaults to `release-<chart appVersion>` when empty. |
| proxy.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. |
| proxy.replicaCount | int | `2` | Number of proxy replicas (ignored when autoscaling.enabled=true). |
| proxy.updateStrategy | string | `"RollingUpdate"` | Deployment update strategy: RollingUpdate or Recreate. |
| proxy.service.type | string | `"ClusterIP"` | Kubernetes Service type for the public proxy service. |
| proxy.service.port | int | `80` | Public service port (nginx itself always listens on container port 80). |
| proxy.env | list | `[]` | Extra environment variables for the proxy container. |
| proxy.logging.level | string | `"error"` | NGINX request log threshold (`error` logs 5xx, `warn` logs 4xx+5xx, `info` logs all requests). |
| proxy.logging.format | string | `"json"` | NGINX log output format. |
| proxy.metrics.enabled | bool | `false` | Expose Prometheus metrics of the proxy (nginx) container (fixed port 9113). |
| proxy.multiChannel | string | `""` | Multi-channel/-site routing configuration (YAML string). |
| proxy.additionalHeaders | string | `""` | Additional response headers configuration (YAML string). |
| proxy.cacheIgnoreParams | string | `""` | Query parameters nginx ignores when caching (YAML string). |
| proxy.reset | object | see [values.yaml](./values.yaml) | Post-upgrade job that restarts the proxy to purge cached SSR pages. |
| proxy.podSecurityContext | object | see [values.yaml](./values.yaml) | Pod security context for the proxy (master runs as root). |
| proxy.securityContext | object | see [values.yaml](./values.yaml) | Container security context for the proxy (adds CHOWN/SETGID/SETUID/DAC_OVERRIDE). |
| proxy.resources | object | see [values.yaml](./values.yaml) | Resource requests/limits for the proxy container. |
| proxy.livenessProbe | object | see [values.yaml](./values.yaml) | Liveness probe for the proxy container (TCP check on the http port). |
| proxy.readinessProbe | object | see [values.yaml](./values.yaml) | Readiness probe for the proxy container (TCP check on the http port). |
| proxy.autoscaling | object | see [values.yaml](./values.yaml) | HorizontalPodAutoscaler for the proxy tier. |
| proxy.nodeSelector | object | `{}` | Node selector for proxy pods. |
| proxy.tolerations | list | `[]` | Tolerations for proxy pods. |
| proxy.affinity | object | `{}` | Node/pod affinity for proxy pods (merged with podAntiAffinity). |
| proxy.podAntiAffinity | object | see [values.yaml](./values.yaml) | Pod anti-affinity to spread proxy replicas across nodes. |
| proxy.podAnnotations | object | `{}` | Extra annotations for proxy pods. |
| proxy.podLabels | object | `{}` | Extra labels for proxy pods. |
| proxy.deploymentAnnotations | object | `{}` | Extra annotations for the proxy Deployment. |
| proxy.deploymentLabels | object | `{}` | Extra labels for the proxy Deployment. |
| ingress.enabled | bool | `false` | Enable creation of Ingress resources. |
| ingress.className | string | `"ingress-haproxy"` | IngressClass name for all instances. |
| monitoring.enabled | bool | `false` | Deploy the in-cluster Prometheus + Grafana stack (development/testing only). |
| monitoring.prometheus | object | see [values.yaml](./values.yaml) | Prometheus image and optional host for the monitoring stack. |
| monitoring.grafana | object | see [values.yaml](./values.yaml) | Grafana image, optional host, and optional dev admin password. |

> [!NOTE]
> Both `proxy.cacheIgnoreParams` and `proxy.multiChannel` take precedence over any `proxy.env` value containing `MULTI_CHANNEL` or `CACHING_IGNORE_PARAMS` variables.

## Validation

The Intershop PWA Helm chart provides a _values.schema.json_ for validation support of the corresponding _values.yaml_ configurations.

For Visual Studio Code, install the plugin `redhat.vscode-yaml` to make use of the already configured validation link in the [_values.yaml_](./values.yaml).

```yaml
# yaml-language-server: $schema=./values.schema.json
```

For the more common Intershop PWA deployments via Flux, the repository also provides validation support for such scenarios through the _values-flux.schema.json_.
Reference this file in the PWA Flux deployment configuration files with a reference to the appropriate version as follows:

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/intershop/helm-charts/pwa-1.0.0/charts/pwa/values-flux.schema.json
```

## Hybrid Approach

The Hybrid Approach allows pages to be served by either the PWA or ICM. For details, see the official Intershop PWA [Hybrid Approach](https://github.com/intershop/intershop-pwa/blob/develop/docs/concepts/hybrid-approach.md) documentation.

```yaml
hybrid:
  enabled: true
  # PWA external port forwarded to the Responsive Starter Store requests
  pwaExternalPort: 443
```

## Multiple Ingresses

Sometimes customers want to go live with only a subset of their domains and want to keep the rest hidden behind IP whitelisting.
A second instance object can be added to the Ingress config to address this use case.
To implement it in your project, follow the example below:

```yaml
ingress:
  enabled: true
  className: ingress-haproxy
  instances:
    # This Ingress has IP whitelisting, so it is hidden from the world, except for IPs xxx.xxx.xxx.xxx and yyy.yyy.yyy.yyy
    ingress-testing:
      hosts:
        # in case multiple PWA instances will be deployed into the given environment
        # namespace, a postfix has to be added to the hostname: i.e., ${pwa-hostname}-edit
        - host: ${pwa_hostname}.pwa.intershop.de
        - host: ${pwa_hostname}-edit.pwa.intershop.de
      tlsSecretName: tls-star-pwa-intershop-de
      annotations:
        kubernetes.io/tls-acme: 'false'
        # xxx.xxx.xxx.xxx and yyy.yyy.yyy.yyy are valid IP-Addresses to be whitelisted
        configuration-snippet: |-
          satisfy any;
          allow xxx.xxx.xxx.xxx;
          allow yyy.yyy.yyy.yyy;
          deny all;
    # This is the 2nd Ingress that is "live" and visible from everywhere
    ingress-live:
      hosts:
        - host: ${pwa_hostname}-live.pwa.intershop.de
      tlsSecretName: tls-star-pwa-intershop-de
      annotations:
        kubernetes.io/tls-acme: 'false'
```

## Pod Anti-Affinity

The PWA Helm chart supports Pod anti-affinity rules to distribute Pods across different nodes in your Kubernetes cluster. This helps improve availability and resilience by ensuring that Pods are spread across the infrastructure.

Pod anti-affinity can be configured for both the app (SSR) Pods and the proxy (nginx) Pods.

```yaml
app:
  podAntiAffinity:
    enabled: true
    required: false

proxy:
  podAntiAffinity:
    enabled: true
    required: false
```

| Property   | Description                                                                                                                                                                                                                                                                        | Default |
| ---------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `enabled`  | Enable or disable Pod anti-affinity rules                                                                                                                                                                                                                                          | `true`  |
| `required` | Use hard anti-affinity rule (`true`) or soft anti-affinity rule (`false`)<br>`true`: requiredDuringSchedulingIgnoredDuringExecution - Pod may stay Pending if no suitable node is available<br>`false`: preferredDuringSchedulingIgnoredDuringExecution - best-effort distribution | `false` |

When `enabled` is set to `true` and `required` is `false` (default), Kubernetes prefers to schedule Pods on different nodes but allow them on the same node if necessary.
This provides a good balance between high availability and scheduling flexibility.

When `required` is set to `true`, Kubernetes enforces that Pods must be scheduled on different nodes.
This provides stronger guarantees but may result in Pods remaining in a pending state if insufficient nodes are available.

## Autoscaling (HPA)

Each tier can be scaled independently by a [HorizontalPodAutoscaler](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) (`autoscaling/v2`) via `app.autoscaling` and `proxy.autoscaling`.
The simple case uses CPU and (optionally) memory target shortcuts:

```yaml
app:
  autoscaling:
    enabled: true
    minReplicas: 4
    maxReplicas: 16
    targetCPUUtilizationPercentage: 1500
    targetMemoryUtilizationPercentage: 80 # optional; omit/null to skip
```

> [!IMPORTANT]
> The target percentage is relative to the container's **resource requests**, not its limits.
> Because the requests are deliberately small, healthy targets are often far above 100 (e.g., `100m` request with a `1500` target ≈ `1500m`).
> This is expected; it is not a typo.

When autoscaling is enabled, the deployment omits `spec.replicas`, so `replicaCount` is ignored and Helm does not interfere with the autoscaler during upgrades.

For finer control, provide scale-up/down `behavior` and/or a raw `metrics` list.
When `metrics` is non-empty, it **replaces** the CPU/memory shortcuts above:

```yaml
proxy:
  autoscaling:
    enabled: true
    minReplicas: 2
    maxReplicas: 4
    targetCPUUtilizationPercentage: 750
    behavior:
      scaleDown:
        stabilizationWindowSeconds: 1800 # scale down only after 30 min below target
      scaleUp:
        stabilizationWindowSeconds: 60
        policies:
          - type: Percent
            value: 100
            periodSeconds: 15
```

Both `metrics` and `behavior` are passed through verbatim, so any `autoscaling/v2` construct (custom/external metrics, per-policy tuning) is supported.

## Pod Labels

To introduce specific labels for the Pods needed for monitoring, change your _values_ file or HelmRelease as follows:

```yaml
# Labels for app (SSR) Pods and deployment
# ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/
app:
  podLabels:
    application-type: pwa
    customer-id: cstmr #Customer Initials
# Labels for proxy (nginx) Pods and deployment
# ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/
proxy:
  podLabels:
    application-type: pwa
    customer-id: cstmr #Customer Initials
```

## Nginx (Proxy) Cache Reset

The cache reset job is a Helm post-upgrade hook that automatically restarts the proxy (nginx) deployment after a Helm upgrade.
This ensures that any cached content is cleared, preventing stale data from being served after PWA SSR container updates.

> [!NOTE]
> The cache reset job replaces the cache init container functionality that was removed in PWA Helm chart 0.12.0 because it did not work as intended in `RollingUpdate` and multi Pod deployments.
> When `cache.init.enabled` was `true`, the init container waited for the PWA SSR service to be ready before starting the nginx/cache service.
> However, this worked as intended only with the `Recreate` update strategy, where no previous SSR Pods could render results that would be cached by new nginx Pods.
> The reset job circumvents this problem by performing a `kubectl rollout restart` on the proxy deployment after all app (SSR) Pods are started successfully and the old Pods are deleted.

The job is executed only when `proxy.reset.enabled` is set to `true`.
It creates the necessary RBAC resources (ServiceAccount, Role, and RoleBinding) with permissions to restart the specific proxy deployment.

Example configuration with public `kubectl` image (internally we use a different default):

```yaml
proxy:
  reset:
    enabled: true
    image:
      repository: bitnami/kubectl
      tag: latest
      pullPolicy: Always
```

| Property  | Description                                                         | Default                                                                                                                 |
| --------- | ------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| `enabled` | Enable or disable the cache reset job after upgrade                 | `true`                                                                                                                  |
| `image`   | Docker image containing `kubectl` for executing the restart command | `repository: ishcp.azurecr.io/ishops/cronjob-utils`<br>&nbsp;&nbsp;`tag: "1"`<br>&nbsp;&nbsp;`pullPolicy: IfNotPresent` |

When enabled, the job runs automatically after each `helm upgrade` operation, ensuring the cache is fresh and consistent with the latest PWA SSR container deployment.

## Prometheus Metrics

To expose the metrics of the app (SSR) and proxy (nginx) containers, both support a per-tier `metrics` configuration.

```yaml
app:
  metrics:
    enabled: true
proxy:
  metrics:
    enabled: true
```

When enabled, each container exposes Prometheus metrics on port 9113.

## Monitoring

For development and testing purposes only, the PWA Helm chart supports monitoring via Prometheus and Grafana.
To enable it, add the following configuration to your _values_ file:

```yaml
monitoring:
  enabled: true
```

This will deploy a Prometheus instance and a Grafana instance.
Both are configured to scrape the metrics of the PWA containers.
The Grafana instance is preconfigured with a dashboard for the PWA metrics.
Both services can be exposed via Ingress.
To expose them, add the following configuration to your _values_ file:

```yaml
monitoring:
  enabled: true
  prometheus:
    host: prometheus.example.com
    annotations: ...
  grafana:
    host: grafana.example.com
    annotations: ...
```

The Grafana access password can be configured via the `monitoring.grafana.password` value.
If not set, the Grafana default password is used.

## Deployment Via Flux

```yaml
# PWA HelmRelease
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: ${namespace}
  namespace: ${namespace}
spec:
  chart:
    spec:
      # pwa helm chart, version from https://github.com/intershop/helm-charts
      chart: pwa
      version: 1.0.0
      # Source reference to the HelmChart Repo
      sourceRef:
        kind: HelmRepository
        name: ish-helm-charts
        namespace: flux-system
  # in case multiple pwa instances will be deployed into the given environment namespace, a postfix has to be added to the
  # release name (i.e. pwa-$ENVIRONMENT-01 or pwa-$ENVIRONMENT-edit)
  releaseName: ${namespace}
  targetNamespace: ${namespace}
  interval: 1m0s
  timeout:
    5m0s
    # Helm Values - to be adapted by the dev team
  values:
    config:
      # required: the ICM base URL the PWA connects to
      icmBaseUrl: https://icm.example.com
```

## Non-Production Deployment

The default [_values.yaml_](./values.yaml) is production-oriented and secure by default.
These defaults (multiple replicas, higher resource requests, Pod anti-affinity across nodes) are not always practical on local, single-node Kubernetes setups such as [kind](https://kind.sigs.k8s.io), [minikube](https://minikube.sigs.k8s.io), [k3d](https://k3d.io), or Docker Desktop.

For these non-production scenarios, the chart ships a dedicated minimal template: [_values-nonproduction.yaml.template_](./values-nonproduction.yaml.template).
It overrides only what is necessary to lower the operational barrier (single replica, reduced resource requests/limits, and disabled Pod anti-affinity so that Pods can schedule on a single node).

> [!WARNING]
> The non-production template is intended for validating and running the chart locally.
> Never use it for production deployments.

To install the chart with the non-production template:

```bash
$ helm install dev-release -f charts/pwa/values-nonproduction.yaml.template charts/pwa
```

You can layer your own overrides on top by passing an additional `-f my-values.yaml` after the template.

## Development

Build and install the current source code version of the Helm chart from the local development folder `charts/pwa` with the given _values_ file _deployment.values.yaml_:

```bash
$ helm dependency build charts/pwa
$ helm install dev-release -f development.values.yaml charts/pwa
```

To render the result of using the current Helm chart, run:

```bash
$ helm template charts/pwa
```

To see the result for a specific given values file, run:

```bash
$ helm template -f development.values.yaml charts/pwa
```

To see the result for a given values file, but only for one specific template (e.g., `deployment.yaml`), run:

```bash
$ helm template -f development.values.yaml -s templates/app-deployment.yaml charts/pwa
```
