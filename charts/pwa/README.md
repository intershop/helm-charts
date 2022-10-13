# Intershop PWA Helm Chart

Installs the [Intershop PWA system](https://github.com/intershop/intershop-pwa) in a kubernetes cluster environment.

## TL;DR
Via command line:
```bash
$ helm repo add intershop https://intershop.github.io/helm-charts
$ helm repo update
$ helm install my-release intershop/pwa-main
```
or via [Flux](https://fluxcd.io) configuration:
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
    version: 0.3.1
  values:
```
## Upgrading an existing Release to a new Major Version

A major chart version change (like v1.2.3 -> v2.0.0) indicates that there is an
incompatible breaking change needing manual actions. These actions will be descibed as part of the release documentation available on GitHub.

## Parameters
### NGinx

| Name                                      | Description                                   |  Example Value                                          |
|-------------------------------------------|-----------------------------------------------|---------------------------------------------------------|
| `cache.multiChannel`                      | Multi channel/site configuration object       | `.+:`<br>`channel: default`                             |
| `cache.cacheIgnoreParams`                 | NGinx ignore query parameters during caching  | `params:`<br>`- utm_source`<br>`- utm_campaign`         |
| `cache.extraEnvVars`                      | Extra environment variables to be set         | `extraEnvVars:`<br>`- name: FOO`<br>  ` value: BAR`     |

Both `cacheIgnoreParams` and `multiChannel` parameters take precedence over any `extraEnvVars` value containing `MULTI_CHANNEL` or `CACHING_IGNORE_PARAMS` variables


## Hybrid mode

Installs the [Intershop PWA and ICM system](https://github.com/intershop/intershop-pwa) all together in a kubernetes cluster environment (same namespace). For more information about the hybrid mode refer to the offical [hybrid approach concept](https://github.com/intershop/intershop-pwa/blob/develop/docs/concepts/hybrid-approach.md).

To configure the PWA Helm chart for that mode you must first set `hybrid.enabled` to `true`. This will activate conditional dependencies to two charts `icm-as` and `icm-web`. Both of which require individual configuration. Please refer to their documentation for details on that. In the end you must add each configuration values object to the `values.yaml` file that reflects your deployment.

Example:
```yaml
image:
  repository: intershophub/intershop-pwa-ssr
...
cache:
  image:
    repository: intershophub/intershop-pwa-nginx
...
icm-as:
  image:
    repository: intershophub/icm-as
...
icm-web:
  webadapter:
    image:
      repository: intershophub/icm-webadapter
...
```

## Parameters
| Name                                      | Description                                   |  Example Value                                          |
|-------------------------------------------|-----------------------------------------------|---------------------------------------------------------|
| `hybrid.enabled`                 | Enable or disable hybrid mode deployment      | `true`                                                  |
| `hybrid.backend.service`         | ICM Web Adapter service name                  | `icm-web`                                               |
| `hybrid.backend.port`            | ICM Web Adapter service port                  | `443`                                                   |
