# Intershop PWA Helm Chart

Installs the [Intershop PWA system](https://github.com/intershop/intershop-pwa) in a kubernetes cluster environment.

## TL;DR
Via command line:
```bash
$ helm repo add intershop https://intershop.github.io/helm-charts
$ helm repo update
$ helm install my-release intershop/pwa --values=values.yaml --namespace pwa
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
    version: 0.2.3
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
