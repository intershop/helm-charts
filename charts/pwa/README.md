# Intershop PWA Helm Chart

Installs the [Intershop PWA system](https://github.com/intershop/intershop-pwa) in a kubernetes cluster environment.

## Get Repo Info

```console
helm repo add intershop https://intershop.github.io/helm-charts
helm repo update
```

_See [helm repo](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Prerequisites
* Helm 3.2.0+
* Kubernetes 1.19+
## Installing the Chart

To install the chart with the release name `demo`:

```console
helm install demo intershop/pwa --values=values.yaml --namespace pwa --timeout 20m0s --wait
```

## Uninstalling the Chart

To uninstall/delete the `demo` deployment:

```console
helm delete demo
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Upgrading an existing Release to a new major version

A major chart version change (like v1.2.3 -> v2.0.0) indicates that there is an
incompatible breaking change needing manual actions.

## Parameters
### NGinx

| Name                                      | Description                                   |  Example Value                                          |
|-------------------------------------------|-----------------------------------------------|---------------------------------------------------------|
| `multiChannel`                            | Multi channel/site configuration object       | `.+:`<br>`channel: default`                             |
| `cacheIgnoreParams`                       | NGinx ignore query parameters during caching  | `params:`<br>`- utm_source`<br>`- utm_campaign`         |
| `extraEnvVars`                            | Extra environment variables to be set         | `extraEnvVars:`<br>`- name: FOO`<br>  ` value: BAR`     |

Both `cacheIgnoreParams` and `multiChannel` parameters take precedence over any `extraEnvVars` value containing `MULTI_CHANNEL` or `CACHING_IGNORE_PARAMS` variables
