# Intershop PWA Helm Chart

Installs the [Intershop PWA](https://github.com/intershop/intershop-pwa) in a Kubernetes cluster environment.

## Installation

### Via Command Line

```bash
$ helm repo add intershop https://intershop.github.io/helm-charts
$ helm repo update
$ helm install my-release intershop/pwa-main
```

## Release Versions

The following table provides an overview of the different PWA Helm Chart versions and the minimum required PWA version to use it with.
In addition, the version changes and necessary migration information is provided.

| Chart  | PWA    | Changes                                                                                                                                                                                                                                                                                                                                                                                                                                 | Migration Information                                                                                                                                                                                                                                                                           |
| ------ | ------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 0.11.0 | 1.0.0  | <ul><li>Add option to enable/disable cache init container</li></ul>                                                                                                                                                                                                                                                                                                                                                                     |                                                                                                                                                                                                                                                                                                 |
| 0.10.0 | 1.0.0  | <ul><li>Change Hybrid Approach handling and configuration options</li><li>Remove dependency to ICM deployment charts</li></ul>                                                                                                                                                                                                                                                                                                          | Removed not used deployment handling introduced with version 0.4.0, new configuration options require PWA 9.1.0                                                                                                                                                                                 |
| 0.9.3  | 1.0.0  | <ul><li>Fix `cache.additionalHeaders` functionality introduced with version 0.8.0</li></ul>                                                                                                                                                                                                                                                                                                                                             |                                                                                                                                                                                                                                                                                                 |
| 0.9.2  | 1.0.0  | <ul><li>Fix options to configure `successfulJobsHistoryLimit` and `failedJobsHistoryLimit` for the prefetch job</li></ul>                                                                                                                                                                                                                                                                                                               |                                                                                                                                                                                                                                                                                                 |
| 0.9.1  | 1.0.0  | <ul><li>Init container image needs to be configurable</li></ul>                                                                                                                                                                                                                                                                                                                                                                         |                                                                                                                                                                                                                                                                                                 |
| 0.9.0  | 1.0.0  | <ul><li>Options to configure `successfulJobsHistoryLimit` and `failedJobsHistoryLimit` for the prefetch job</li><li>Make prefetch job `args` and `image` configurable</li><li>Provide validation support for Flux configurations</li></ul>                                                                                                                                                                                              |                                                                                                                                                                                                                                                                                                 |
| 0.8.0  | 1.0.0  | <ul><li>New format of declaring (multiple) Ingresses (Split Ingress)</li><li>Shared Redis cache for the nginx containers (requires PWA 5.0.0)</li><li>Additional result headers configuration (requires PWA 5.0.0)</li><li>Monitoring support with Prometheus and Grafana (for development and testing)</li><li>Delay NGINX until PWA SSR is listening</li><li>Configurable update strategy</li><li>Less verbose prefetch job</li></ul> | See [Migration to 0.8.0](https://github.com/intershop/helm-charts/blob/main/charts/pwa/docs/migrate-to-0.8.0.md) in regards to the new format of configuring Ingress and the dropped support of older kubernetes clusters<br/>Configurable `updateStrategy` stays at `RollingUpdate` by default |
| 0.7.0  | 1.0.0  | <ul><li>Re-enabled support for `multi-channel.yaml` and `caching-ignore-params.yaml` source code fallbacks</li><li>Added additional Ingress for domain whitelisting</li><li>Added labels on deployment and pod levels</li></ul>                                                                                                                                                                                                         | Removed deprecated configuration options:<ul><li>`upstream.icm`</li><li>`cache.enabled` - was not optional</li><li>`cache.channels`</li></ul>See [Migration to 0.7.0](https://github.com/intershop/helm-charts/blob/main/charts/pwa/docs/migrate-to-0.7.0.md)                                   |
| 0.6.0  | 1.0.0  | Support for Prometheus metrics                                                                                                                                                                                                                                                                                                                                                                                                          |                                                                                                                                                                                                                                                                                                 |
| 0.5.0  | 1.0.0  | Added prefetch job that can heat up caches                                                                                                                                                                                                                                                                                                                                                                                              |                                                                                                                                                                                                                                                                                                 |
| 0.4.0  | 1.0.0  | Support for PWA Hybrid Approach deployment (with ICM 11)                                                                                                                                                                                                                                                                                                                                                                                | Requires PWA 3.2.0 for Hybrid Approach support                                                                                                                                                                                                                                                  |
| 0.3.0  | 1.0.0  | Use new Ingress controller definition                                                                                                                                                                                                                                                                                                                                                                                                   | See [Migration to 0.3.0](https://github.com/intershop/helm-charts/blob/main/charts/pwa/docs/migrate-to-0.3.0.md)                                                                                                                                                                                |
| 0.2.4  | 0.25.0 | Support for `multiChannel`, `cacheIgnoreParams` and `extraEnvVars` for nginx/cache deployment                                                                                                                                                                                                                                                                                                                                           | Missing support for `multi-channel.yaml` and `caching-ignore-params.yaml` source code fallbacks                                                                                                                                                                                                 |
| 0.2.3  | 0.25.0 | Legacy Helm Chart 0.2.3 as initial version                                                                                                                                                                                                                                                                                                                                                                                              |                                                                                                                                                                                                                                                                                                 |

## Parameters

### General

| Name             | Description                    | Example Value                                |
| ---------------- | ------------------------------ | -------------------------------------------- |
| `updateStrategy` | The Kubernetes update strategy | `Recreate`<br>`RollingUpdate`&nbsp;(default) |

### NGINX

| Name                      | Description                                                | Example Value                                                                                                                                             |
| ------------------------- | ---------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `cache.extraEnvVars`      | Extra environment variables to be set                      | `- name: FOO`<br>&nbsp;&nbsp;&nbsp;&nbsp;`value: BAR`                                                                                                     |
| `cache.multiChannel`      | Multi-channel/site configuration object                    | `.+:`<br>&nbsp;&nbsp;`channel: default`                                                                                                                   |
| `cache.cacheIgnoreParams` | NGINX ignore query parameters during caching               | `params:`<br>&nbsp;&nbsp;`- utm_source`<br>&nbsp;&nbsp;`- utm_campaign`                                                                                   |
| `cache.additionalHeaders` | Additional result headers configuration                    | `headers:`<br>&nbsp;&nbsp;`- X-Frame-Options: 'SAMEORIGIN'`                                                                                               |
| `cache.prefetch`          | Specify settings for the prefetch job that heats up caches | `prefetch:`<br>&nbsp;&nbsp;`- host: example.com`<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`path: /home`                                                     |
| `cache.init`              | Specify settings for the init container                    | `init:`<br>&nbsp;&nbsp;`enabled: true`<br>&nbsp;&nbsp;`image:`<br/>&nbsp;&nbsp;&nbsp;&nbsp;`repository: busybox`<br>&nbsp;&nbsp;&nbsp;&nbsp;`tag: 1.37.0` |

> [!NOTE]
> Both `cacheIgnoreParams` and `multiChannel` parameters take precedence over any `extraEnvVars` value containing `MULTI_CHANNEL` or `CACHING_IGNORE_PARAMS` variables.

### Hybrid Approach

For more information about the Hybrid Approach, refer to the official Intershop PWA [Hybrid Approach](https://github.com/intershop/intershop-pwa/blob/develop/docs/concepts/hybrid-approach.md) documentation.

| Name                     | Description                                                                            | Example Value                        |
| ------------------------ | -------------------------------------------------------------------------------------- | ------------------------------------ |
| `hybrid.enabled`         | Enable or disable Hybrid Approach deployment                                           | `true`                               |
| `hybrid.icmInternalURL`  | ICM Web Adapter service internal kubernetes URL                                        | `https://kubernetes-icm-web-wa:8443` |
| `hybrid.pwaExternalPort` | The PWAs external port that will be forwarded to the Responsive Starter Store requests | `443`                                |

## Shared Redis Cache

> [!IMPORTANT]
> The shared Redis cache for the nginx containers requires Intershop PWA version 5.0.0 or newer.

The PWA Helm chart supports a shared Redis cache for the nginx containers. To enable it, add the following configuration to your values file:

```yaml
redis:
  uri: rediss://user:password@redis.cloud.com:6379
  # keepCache: true
```

Unless `keepCache` is explicitly set to `true`, the cache will be flushed on every deployment using `redis-cli` with a `flushdb` command on the supplied URI.

This chart does not deploy a Redis instance. You must provide one yourself. We recommend using a cloud service.

If you want to deploy a Redis instance yourself, be aware that the PWA implementation does not support Redis Cluster or Redis Sentinel connections.

## NGINX Cache Prefetch

The prefetch job is implemented as `wget` in recursive spider mode with level limit `0`. This means that it follows all the links it finds in the first requested page. The link to the first page is created by the given Helm chart values. Since one PWA deployment can host multiple sites, you can provide prefetch config values as array items.

Example:

```yaml
prefetch:
  - host: customer-int.pwa.intershop.de
    path: /b2c/home
    cron: "0 23 * * *"
```

The example above configures the prefetch to happen every day at 11:00 pm. It will request the initial page at https://customer-int.pwa.intershop.de/b2c/home.

The only mandatory property is `host` – used to specify the fully qualified name for your site. This host must be contained in your Ingress configuration. All other properties have reasonable defaults.

| Property                   | Default                                                                                                                                                        |
| -------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| path                       | `/`                                                                                                                                                            |
| protocol                   | `https`                                                                                                                                                        |
| cron                       | `0 0 * * *`                                                                                                                                                    |
| stop                       | `3600`                                                                                                                                                         |
| args                       | `'--timeout=15', '--spider', '--no-check-certificate', '--retry-connrefused', '--tries=5', '--execute=robots=off', '--recursive', '--level=0', '--no-verbose'` |
| image                      | `31099/wget:alpine-3.19`                                                                                                                                       |
| successfulJobsHistoryLimit | `0`                                                                                                                                                            |
| failedJobsHistoryLimit     | `1`                                                                                                                                                            |

The value for `cron` determines the schedule of the prefetch job. You can search the internet for "cron tab syntax" or use [tooling](https://crontab.guru) to come up with a correct value.

The value for `stop` determines the duration in seconds after the job is forcefully stopped. Forcefully stopping is still considered to be a successful run for container/job.

The value for `args` provides a way to override the current default arguments of the `wget` configuration.
When overriding the complete set of intended arguments needs to be provided.

The value for `image` can be used to override the default [adapted `wget` image](https://github.com/jometzner/wget) or to update to a different version via the PWA deployment configuration.

The Kubernetes [Jobs history limits](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/#jobs-history-limits) can be set individually for each prefetch job configuration via `successfulJobsHistoryLimit` and `failedJobsHistoryLimit`.

## Multiple Ingress

Sometimes customers only want to go live with a subset of their domains, but want to keep the rest hidden behind IP whitelisting. Therefore, a second instance object can be added to the ingress config to address this use case.
To implement it in your project, follow the example below:

```yaml
ingress:
  enabled: true
  className: nginx
  instances:
    # This Ingress has IP whitelisting, so it is hidden from the world, except for IPs xxx.xxx.xxx.xxx and yyy.yyy.yyy.yyy
    ingress-testing:
      hosts:
        # in case multiple PWA instances will be deployed into the given environment
        # namespace, a postfix has to be added to the hostname: i.e. ${pwa-hostname}-edit
        - host: ${pwa_hostname}.pwa.intershop.de
        - host: ${pwa_hostname}-edit.pwa.intershop.de
      tlsSecretName: tls-star-pwa-intershop-de
      annotations:
        kubernetes.io/tls-acme: "false"
        # xxx.xxx.xxx.xxx and yyy.yyy.yyy.yyy are valid IP-Addresses to be whitelisted
        configuration-snippet: |-
          satisfy any;
          allow xxx.xxx.xxx.xxx;
          allow yyy.yyy.yyy.yyy;
          deny all;
    # This is the 2nd ingress that is "live" and visible from everywhere
    ingress-live:
      hosts:
        - host: ${pwa_hostname}-live.pwa.intershop.de
      tlsSecretName: tls-star-pwa-intershop-de
      annotations:
        kubernetes.io/tls-acme: "false"
```

## Pod Labels

To introduce specific labels for the Pods needed for monitoring, change your values file or HelmRelease to the following:

```yaml
### @param podLabels labels for SSR pods and deployment
### ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/
podLabels:
  application-type: pwa
  customer-id: cstmr #Customer Initials
### @param podLabels labels for NGINX/Cache pods and deployment
### ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/
cache:
  podLabels:
    application-type: pwa
    customer-id: cstmr #Customer Initials
```

## Prometheus Metrics

To expose the metrics of the SSR and the nginx containers, both support the `metrics` configuration via Helm chart.

```yaml
metrics:
  enabled: true
```

When enabled, the SSR container will expose the metrics in the deployment cluster on port 9113, while the nginx container exposes its metrics on port 9114 at the `/metrics` endpoint.

## Deployment via Flux Repository

### Using [Flux](https://fluxcd.io) v1

```yaml
apiVersion: helm.fluxcd.io/v1
kind: HelmRelease
metadata:
  name: xxx-yyy
  namespace: xxx-yyy

spec:
  rollback:
    enable: true
    force: true
  wait: true
  timeout: 270
  releaseName: xxx-yyy
  chart:
    repository: https://intershop.github.io/helm-charts
    name: pwa-main
    version: 0.10.0
  values:
```

### Using [Flux](https://fluxcd.io) v2

Here you create a HelmRepository resource in addition to the HelmRelease [(helm-operator-migration Guide from Flux v1 to Flux v2)](https://fluxcd.io/flux/migration/helm-operator-migration/)

```yaml
---
apiVersion: source.toolkit.fluxcd.io/v1beta2
kind: HelmRepository
metadata:
  name: ish-helm-charts
  namespace: flux-system
spec:
  interval: 1m0s
  url: https://intershop.github.io/helm-charts

---
# PWA HelmRelease
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: ${namespace}
  namespace: ${namespace}
spec:
  chart:
    spec:
      # pwa helm chart, version from https://github.com/intershop/helm-charts
      chart: pwa-main
      version: 0.10.0
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
```

## Monitoring

The PWA Helm chart supports monitoring via Prometheus and Grafana. To enable it, add the following configuration to your values file:

```yaml
monitoring:
  enabled: true
```

This will deploy a Prometheus instance and a Grafana instance. Both are configured to scrape the metrics of the PWA containers. The Grafana instance is preconfigured with a dashboard for the PWA metrics.
Both services can be exposed via Ingress. To expose them add the following configuration to your values file:

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

The grafana access password can be configured via the `monitoring.grafana.password` value. If not set, a default password will be used.

## Validation

The Intershop PWA Helm Chart provides a `values.schema.json` for validation support of the according `values.yaml` configurations.

For Visual Studio Code the plugin `redhat.vscode-yaml` needs to be installed to make use of the already configured validation link in the [`values.yaml`](./values.yaml).

```yaml
# yaml-language-server: $schema=./values.schema.json
```

For the more common Intershop PWA deployments via Flux the repository also provides validation support for such scenarios through the `values-flux.schema.json`.
This file needs to be referenced in the PWA Flux deployment configuration files with a reference to the fitting version in the following way.

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/intershop/helm-charts/pwa-main-0.10.0/charts/pwa/values-flux.schema.json
```

## Development

Build and install the current source code version of the Helm chart from the local development folder `helm-charts/charts/pwa` with the given values file `deployment.values.yaml`:

```bash
$ helm dependency build helm-charts/charts/pwa
$ helm install dev-release -f development.values.yaml helm-charts/charts/pwa
```

To simply render the result of using the current Helm chart, run:

```bash
$ helm template helm-charts/charts/pwa
```

To see the result for a specific given values file, run:

```bash
$ helm template -f development.values.yaml helm-charts/charts/pwa
```

To see the result for a given values file, but only for one specific template (e.g. `deployment.yaml`), run:

```bash
$ helm template -f development.values.yaml -s templates/deployment.yaml helm-charts/charts/pwa
```
