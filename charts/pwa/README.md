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
    version: 0.6.0
  values:
```

## Upgrading an existing Release to a new Major Version

A major chart version change (like v1.2.3 -> v2.0.0) indicates that there is an
incompatible breaking change needing manual actions. These actions will be descibed as part of the release documentation available on GitHub.

## Parameters

### NGinx

| Name                      | Description                                                | Example Value                                           |
| ------------------------- | ---------------------------------------------------------- | ------------------------------------------------------- |
| `cache.multiChannel`      | Multi channel/site configuration object                    | `.+:`<br>`channel: default`                             |
| `cache.cacheIgnoreParams` | NGinx ignore query parameters during caching               | `params:`<br>`- utm_source`<br>`- utm_campaign`         |
| `cache.extraEnvVars`      | Extra environment variables to be set                      | `extraEnvVars:`<br>`- name: FOO`<br> ` value: BAR`      |
| `cache.prefetch`          | Specify settings for the prefetch job that heats up caches | `prefetch:`<br>`- host: example.com`<br> ` path: /home` |

Both `cacheIgnoreParams` and `multiChannel` parameters take precedence over any `extraEnvVars` value containing `MULTI_CHANNEL` or `CACHING_IGNORE_PARAMS` variables

### SSR

| Name                     | Description                              | Example Value |
| ------------------------ | ---------------------------------------- | ------------- |
| `hybrid.enabled`         | Enable or disable hybrid mode deployment | `true`        |
| `hybrid.backend.service` | ICM Web Adapter service name             | `icm-web`     |
| `hybrid.backend.port`    | ICM Web Adapter service port             | `443`         |

## Hybrid mode

Installs the [Intershop PWA and ICM system](https://github.com/intershop/intershop-pwa) all together in a kubernetes cluster environment (same namespace). For more information about the hybrid mode refer to the offical [hybrid approach concept](https://github.com/intershop/intershop-pwa/blob/develop/docs/concepts/hybrid-approach.md).

To configure the PWA Helm chart for that mode you must first set `hybrid.enabled` to `true`. This will activate conditional dependencies to one umbrella chart `icm` that itself depends on `icm-as` and `icm-web`. Both of which require individual configuration. Please refer to their documentation for details on that. In the end you must add each configuration values object to the `values.yaml` file that reflects your deployment.

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

## NGinx cache prefetch

The prefetch job is implemented as `wget` in recursive spider mode with level limit 0. This means it is following all links it found in the initial requested page. The link to that first page will be created by the given helm chart values. Since one PWA deployment can host several sites you can provide prefetch config values as array items.

Example:

```yaml
prefetch:
  - host: customer-int.pwa.intershop.de
    path: /b2c/home
    protocol: https
    cron: "0 23 * * *"
```

The above example configures the prefetch to happen everyday at 11:00 pm. It will request the initial page at https://customer-int.pwa.intershop.de/b2c/home

The only mandatory property is `host` to denote the full qualified name for your site. That host has to be contained in your ingress configuration. All other properties have reasonable defaults.

| Property | Default     |
| -------- | ----------- |
| path     | `/`         |
| protocol | `https`     |
| cron     | `0 0 * * *` |
| stop     | `3600`      |

The value for `cron` determines the schedule of the prefetch job. You can search the internet for "cron tab syntax" or use [tooling](https://crontab.guru) to come up with a correct value.

The value for `stop` determines the duration in seconds after the job is forcefully stopped. Forcefully stopping is still considered to be a successful run for container/job.

## Prometheus Metrics

To expose metrics of the SSR and the nginx containers both support the `metrics` configuration via helm chart.

```yaml
metrics:
  enabled: true
```

When enabled the SSR will expose the metrics in the deployment cluster on port 9113 while the nginx exposes its metrics on port 9114 each at the `/metrics` endpoint.
