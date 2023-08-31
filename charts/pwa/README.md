# Intershop PWA Helm Chart

Installs the [Intershop PWA](https://github.com/intershop/intershop-pwa) in a Kubernetes cluster environment.

## Installation

### Via Command Line

```bash
$ helm repo add intershop https://intershop.github.io/helm-charts
$ helm repo update
$ helm install my-release intershop/pwa-main
```

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
    version: 0.8.0-gamma
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
      version: 0.8.0-gamma
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
  timeout: 5m0s
   # Helm Values - to be adapted by the dev team
  values:
```

## Release Versions

The following table provides an overview of the different PWA Helm Chart versions and the minimum required PWA version to use it with.
In addition, the version changes and necessary migration information is provided.

| Chart | PWA    | Changes                                                                                                                                                                                           | Migration Information                                                                                                                                                                                                                        |
| ----- | ------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 0.7.0 | 1.0.0  | <ul><li>Re-enabled support for `multi-channel.yaml` and `caching-ignore-params.yaml` source code fallbacks</li><li>Added additional Ingress for domain whitelisting</li><li>Added labels on deployment and pod levels</li> | Removed deprecated configuration options:<ul><li>`upstream.icm`</li><li>`cache.enabled` - was not optional</li><li>`cache.channels`</li></ul>See [Migration to 0.7.0](https://github.com/intershop/helm-charts/blob/main/charts/pwa/docs/migrate-to-0.7.0.md) |
| 0.6.0 | 1.0.0  | Support for Prometheus metrics                                                                                                                                                                        |                                                                                                                                                                                                                                              |
| 0.5.0 | 1.0.0  | Added prefetch job that can heat up caches                                                                                                                                                          |                                                                                                                                                                                                                                              |
| 0.4.0 | 1.0.0  | Support for PWA Hybrid Approach deployment (with ICM 11)                                                                                                                                                  | Requires PWA 3.2.0 for Hybrid Approach support                                                                                                                                                                                                   |
| 0.3.0 | 1.0.0  | Use new Ingress controller definition                                                                                                                                                             | [Migration to 0.3.0](https://github.com/intershop/helm-charts/blob/main/charts/pwa/docs/migrate-to-0.3.0.md)                                                                                                                                 |
| 0.2.4 | 0.25.0 | Support for `multiChannel`, `cacheIgnoreParams` and `extraEnvVars` for nginx/cache deployment                                                                                                     | Missing support for `multi-channel.yaml` and `caching-ignore-params.yaml` source code fallbacks                                                                                                                                              |
| 0.2.3 | 0.25.0 | Legacy Helm Chart 0.2.3 as initial version                                                                                                                                                        |                                                                                                                                                                                                                                              |

### Upgrading an Existing Release to a New Major Version

A major chart version change (like v1.2.3 -> v2.0.0) indicates that there is an incompatible breaking change that requires manual actions.
These actions will be described as part of the release documentation available on GitHub.

## Parameters

### NGINX

| Name                      | Description                                                | Example Value                                           |
| ------------------------- | ---------------------------------------------------------- | ------------------------------------------------------- |
| `cache.multiChannel`      | Multi-channel/site configuration object                    | `.+:`<br>`channel: default`                             |
| `cache.cacheIgnoreParams` | NGINX ignore query parameters during caching               | `params:`<br>`- utm_source`<br>`- utm_campaign`         |
| `cache.extraEnvVars`      | Extra environment variables to be set                      | `extraEnvVars:`<br>`- name: FOO`<br> ` value: BAR`      |
| `cache.prefetch`          | Specify settings for the prefetch job that heats up caches | `prefetch:`<br>`- host: example.com`<br> ` path: /home` |

Both `cacheIgnoreParams` and `multiChannel` parameters take precedence over any `extraEnvVars` value containing `MULTI_CHANNEL` or `CACHING_IGNORE_PARAMS` variables.

### SSR (Server-Side Rendering)

| Name                     | Description                                  | Example Value |
| ------------------------ | -------------------------------------------- | ------------- |
| `hybrid.enabled`         | Enable or disable Hybrid Approach deployment | `true`        |
| `hybrid.backend.service` | ICM Web Adapter service name                 | `icm-web`     |
| `hybrid.backend.port`    | ICM Web Adapter service port                 | `443`         |

## Hybrid Approach

Installs the [Intershop PWA and ICM system](https://github.com/intershop/intershop-pwa) all together in a Kubernetes cluster environment (same namespace). For more information about the Hybrid Approach, refer to the official [hybrid Approach concept](https://github.com/intershop/intershop-pwa/blob/develop/docs/concepts/hybrid-approach.md).

To configure the PWA Helm chart for this mode, you must first set `hybrid.enabled` to `true`. This will activate conditional dependencies to an umbrella chart `icm`, which depends on `icm-as` and `icm-web`. Both require individual configuration. Please refer to their documentation for details. Finally, you must add each configuration values object to the `values.yaml` file that reflects your deployment.

Example:

```yaml
image:
  repository: intershophub/intershop-pwa-ssr
---
cache:
  image:
    repository: intershophub/intershop-pwa-nginx
---
icm:
  icm-as:
    image:
      repository: intershophub/icm-as
---
icm-web:
  webadapter:
    image:
      repository: intershophub/icm-webadapter
```

## NGINX Cache Prefetch

The prefetch job is implemented as `wget` in recursive spider mode with level limit `0`. This means that it follows all the links it finds in the first requested page. The link to the first page is created by the given Helm chart values. Since one PWA deployment can host multiple sites, you can provide prefetch config values as array items.

Example:

```yaml
prefetch:
  - host: customer-int.pwa.intershop.de
    path: /b2c/home
    protocol: https
    cron: "0 23 * * *"
```

The example above configures the prefetch to happen every day at 11:00 pm. It will request the initial page at https://customer-int.pwa.intershop.de/b2c/home.

The only mandatory property is `host` – used to specify the fully qualified name for your site. This host must be contained in your Ingress configuration. All other properties have reasonable defaults.

| Property | Default     |
| -------- | ----------- |
| path     | `/`         |
| protocol | `https`     |
| cron     | `0 0 * * *` |
| stop     | `3600`      |

The value for `cron` determines the schedule of the prefetch job. You can search the internet for "cron tab syntax" or use [tooling](https://crontab.guru) to come up with a correct value.

The value for `stop` determines the duration in seconds after the job is forcefully stopped. Forcefully stopping is still considered to be a successful run for container/job.

## Split Ingress

Sometimes customers only want to go live with a subset of their domains, but want to keep the rest hidden behind IP whitelisting. Therefore, a second Ingress object was implemented to address this use case.
`ingresssplit` is disabled by default. To implement it in your project, follow the example below:

```yaml
# This Ingress has IP whitelisting, so it is hidden from the world, except for IPs xxx.xxx.xxx.xxx and yyy.yyy.yyy.yyy
ingress:
  enabled: true
  className: nginx
  annotations:
    kubernetes.io/tls-acme: "false"
    # xxx.xxx.xxx.xxx and yyy.yyy.yyy.yyy are valid IP-Addresses to be whitelisted
    configuration-snippet: |-
      satisfy any;
      allow xxx.xxx.xxx.xxx;
      allow yyy.yyy.yyy.yyy;
      deny all;
  hosts:
  # in case multiple PWA instances will be deployed into the given environment namespace, a postfix
  # has to be added to the hostname: i.e. ${pwa-hostname}-edit
  - host: ${pwa_hostname}.pwa.intershop.de
    paths:
    - path: /
      pathType: ImplementationSpecific
  tls:
  - secretName: tls-star-pwa-intershop-de
# This is the 2nd ingress that is "live" and visible from everywhere
ingresssplit:
  enabled: true
  className: nginx
  annotations:
    kubernetes.io/tls-acme: "false"
    nginx.ingress.kubernetes.io/
  hosts:
  # in case multiple PWA instances will be deployed into the given environment namespace, a postfix
  # has to be added to the hostname: i.e. ${pwa-hostname}-split-edit
  - host: ${pwa_hostname}-split.pwa.intershop.de
    paths:
    - path: /
      pathType: ImplementationSpecific
  tls:
  - secretName: tls-star-pwa-intershop-de
```
Please pay attention to which API version of networking.k8s.io you are using. Check [this document](/charts/pwa/docs/migrate-to-0.3.0.md) for differences between the implementations.

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

---

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
