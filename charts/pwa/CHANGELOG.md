<a name="pwa-1.0.0-memcached.1"></a>
# [pwa-1.0.0-memcached.1](https://github.com/intershop/helm-charts/releases/tag/pwa-1.0.0-memcached.1) (2026-11-10)

Compare with previous release: [pwa-1.0.0...pwa-1.0.0-memcached.1](https://github.com/intershop/helm-charts/compare/pwa-1.0.0...pwa-1.0.0-memcached.1)

## Notes

**Special build:** PWA Helm Chart 1.0.0 with a shared Memcached cache for the proxy tier. It replaces the `pwa-main` `0.7.1-memcached.N` builds (last: `pwa-main-0.7.1-memcached.4`).

All 1.0.0 changes apply. Read the [Migration to 1.0.0](https://github.com/intershop/helm-charts/blob/pwa-1.0.0-memcached.1/charts/pwa/docs/migrate-to-1.0.0.md) guide before upgrading, in particular the [Memcached Builds](https://github.com/intershop/helm-charts/blob/pwa-1.0.0-memcached.1/charts/pwa/docs/migrate-to-1.0.0.md#memcached-builds) section.

* **Values moved:** `cache.memcached` is now `proxy.memcached`. `proxy.memcached.args` stays a JSON array represented as a string.
* **Memcached Service renamed:** `<release>-pwa-main-memcached` is now `<pwa fullname>-memcached`; for example, `pwa-shop-pwa-main-memcached` becomes `pwa-shop-memcached`. Update anything that connects to it by name, such as a `prometheus-memcached-exporter` `memcached.address`.
* **Service type:** the Memcached Service no longer follows `cache.service.type`; `proxy.memcached.service.type` defaults to `ClusterIP`.
* **Managed env:** the chart sets `MEMCACHED_HOSTNAME` in the proxy container; a `proxy.env` entry for it fails the render.
* **Image:** the default Memcached image is now `memcached:1.6.45` (was `1.6.21`).
* **Not ported:** the prefetch job changes of the 0.7.1 Memcached builds, because 1.0.0 removed `cache.prefetch`.

## Features

* shared Memcached cache for the proxy tier (`proxy.memcached`): one Memcached Deployment and Service, `MEMCACHED_HOSTNAME` pointing the proxy at it
* the migration script migrates `pwa-main` `0.7.1-memcached.N` releases to this version:
  * maps `cache.memcached` to `proxy.memcached` and drops `MEMCACHED_HOSTNAME` from `proxy.env`
  * finds references to the renamed Memcached Service in the release's folder and rewrites them; `--subst KEY=VALUE` resolves Flux variables such as `${namespace}` in release names
  * `--target-version` defaults to `1.0.0-memcached.1` for these releases; new option `--subst`



<a name="pwa-1.0.0"></a>
# [pwa-1.0.0](https://github.com/intershop/helm-charts/releases/tag/pwa-1.0.0) (2026-11-06)

Compare with previous release: [pwa-main-0.13.0...pwa-1.0.0](https://github.com/intershop/helm-charts/compare/pwa-main-0.13.0...pwa-1.0.0)

## Notes

**BREAKING:** 1.0.0 is a major restructure: almost every value has moved or been renamed. Read the [Migration to 1.0.0](https://github.com/intershop/helm-charts/blob/pwa-1.0.0/charts/pwa/docs/migrate-to-1.0.0.md) guide before upgrading.

* **Chart renamed** from `pwa-main` to `pwa`: use `intershop/pwa` (Helm) or `spec.chart.spec.chart: pwa` (Flux). Release tags are now `pwa-X.Y.Z`; `pwa-main` is no longer published.
* **Tiers renamed:** top-level SSR values are now under `app`, `cache` is now `proxy`. Resources `<release>-pwa-main` / `<release>-pwa-main-cache` are now `<release>-pwa-app` / `<release>-pwa-proxy`, so update anything that selects them by name.
* **Removed values:** `cache.prefetch` (prefetch job), `upstream.cdnPrefixURL`, `calculated`.
* **Changed defaults:** non-root containers, probes for both tiers, image tag `release-<appVersion>` with `IfNotPresent`, 2 replicas and resource requests/limits per tier, `bitnami/kubectl` reset image, proxy log level `info`, Ingress class `ingress-haproxy`.
* **Migration help:** `scripts/migrate-to-1.0.0.py` converts values files and Flux `HelmRelease`s. Leftover 0.x keys fail the render with a message naming their replacement.
* **Requirements:** Helm >= 4.0.0, Kubernetes >= 1.23.

## Features

* **pwa:** introduce PWA Helm Chart 1.0.0 ([#1310](https://github.com/intershop/helm-charts/issues/1310))
  * explicit `app` and `proxy` tiers with optional HorizontalPodAutoscalers
  * ServiceAccount and namespaced RBAC for the proxy cache reset
  * strict values schema and a non-production values template for local clusters
  * `helm test` connection test


<a name="pwa-main-0.13.0"></a>
# [pwa-main-0.13.0](https://github.com/intershop/helm-charts/releases/tag/pwa-main-0.13.0) (2026-06-02)

Compare with previous release: [pwa-main-0.12.0...pwa-main-0.13.0](https://github.com/intershop/helm-charts/compare/pwa-main-0.12.0...pwa-main-0.13.0)

## Features

* **pwa:** add pod anti affinity

## Documentation

* documentation clarification in regards to "Cache reset enabled by default" ([#1264](https://github.com/intershop/helm-charts/issues/1264))


<a name="pwa-main-0.12.0"></a>
# [pwa-main-0.12.0](https://github.com/intershop/helm-charts/releases/tag/pwa-main-0.12.0) (2026-01-23)

Compare with previous release: [pwa-main-0.11.0...pwa-main-0.12.0](https://github.com/intershop/helm-charts/compare/pwa-main-0.11.0...pwa-main-0.12.0)

## Bug Fixes

* cleanup/improve cache reset feature ([#1184](https://github.com/intershop/helm-charts/issues/1184))

## Documentation

* documentation improvements in PWA Helm Charts ([#1183](https://github.com/intershop/helm-charts/issues/1183))


<a name="pwa-main-0.11.0"></a>
# [pwa-main-0.11.0](https://github.com/intershop/helm-charts/releases/tag/pwa-main-0.11.0) (2025-12-18)

Compare with previous release: [pwa-main-0.10.0...pwa-main-0.11.0](https://github.com/intershop/helm-charts/compare/pwa-main-0.10.0...pwa-main-0.11.0)

## Features

* introduce options for explicit deployment labels and deployment annotations
* provide option to change the `redis-cli` image for the Redis cache flush job ([#1174](https://github.com/intershop/helm-charts/issues/1174))
* introduce NGINX/cache reset after deployment via hook job ([#1174](https://github.com/intershop/helm-charts/issues/1174))
* add option to enable/disable init container ([#1174](https://github.com/intershop/helm-charts/issues/1174))


<a name="pwa-main-0.10.0"></a>
# [pwa-main-0.10.0](https://github.com/intershop/helm-charts/releases/tag/pwa-main-0.10.0) (2025-12-03)

Compare with previous release: [pwa-main-0.9.3...pwa-main-0.10.0](https://github.com/intershop/helm-charts/compare/pwa-main-0.9.3...pwa-main-0.10.0)

## Features

* reworked PWA Hybrid Approach deployment ([#1158](https://github.com/intershop/helm-charts/issues/1158))


<a name="pwa-main-0.9.3"></a>
# [pwa-main-0.9.3](https://github.com/intershop/helm-charts/releases/tag/pwa-main-0.9.3) (2025-02-19)

Compare with previous release: [pwa-main-0.9.2...pwa-main-0.9.3](https://github.com/intershop/helm-charts/compare/pwa-main-0.9.2...pwa-main-0.9.3)

## Bug Fixes

* **pwa:** fixed `cache.additionalHeaders` functionality introduced with version 0.8.0


<a name="pwa-main-0.9.2"></a>
# [pwa-main-0.9.2](https://github.com/intershop/helm-charts/releases/tag/pwa-main-0.9.2) (2024-09-18)

Compare with previous release: [pwa-main-0.9.1...pwa-main-0.9.2](https://github.com/intershop/helm-charts/compare/pwa-main-0.9.1...pwa-main-0.9.2)

## Features

* **pwa:** fix for "add options to configure `successfulJobsHistoryLimit` and `failedJobsHistoryLimit` for the prefetch job"

## Bug Fixes

* **pwa:** container image should be configurable ([#717](https://github.com/intershop/helm-charts/issues/717))


<a name="pwa-main-0.9.1"></a>
# [pwa-main-0.9.1](https://github.com/intershop/helm-charts/releases/tag/pwa-main-0.9.1) (2024-07-02)

Compare with previous release: [pwa-main-0.9.0...pwa-main-0.9.1](https://github.com/intershop/helm-charts/compare/pwa-main-0.9.0...pwa-main-0.9.1)

## Bug Fixes

* **pwa:** container image should be configurable ([#717](https://github.com/intershop/helm-charts/issues/717))


<a name="pwa-main-0.9.0"></a>
# [pwa-main-0.9.0](https://github.com/intershop/helm-charts/releases/tag/pwa-main-0.9.0) (2024-04-24)

Compare with previous release: [pwa-main-0.8.0...pwa-main-0.9.0](https://github.com/intershop/helm-charts/compare/pwa-main-0.8.0...pwa-main-0.9.0)

## Features

* **pwa:** add options to configure `successfulJobsHistoryLimit` and `failedJobsHistoryLimit` for the prefetch job ([#629](https://github.com/intershop/helm-charts/issues/629))
* **pwa:** make prefetch job 'image' configurable
* **pwa:** make prefetch job 'args' configurable
* **pwa:** provide values configuration files validation support for Flux deployment configurations

## Bug Fixes

* improve restart display on grafana dashboard ([#626](https://github.com/intershop/helm-charts/issues/626))

## Documentation

* **pwa:** improve PWA Helm Chart 0.8.0 migration documentation ([#628](https://github.com/intershop/helm-charts/issues/628))


<a name="pwa-main-0.8.0"></a>
# [pwa-main-0.8.0](https://github.com/intershop/helm-charts/releases/tag/pwa-main-0.8.0) (2024-01-04)

Compare with previous release: [pwa-main-0.7.0...pwa-main-0.8.0](https://github.com/intershop/helm-charts/compare/pwa-main-0.7.0...pwa-main-0.8.0)

## Features

* **pwa:** option to add additional headers to NGINX results ([#489](https://github.com/intershop/helm-charts/issues/489))
* **pwa:** shared Redis cache config and flush job ([#401](https://github.com/intershop/helm-charts/issues/401))
* **pwa:** new format of declaring (multiple) Ingresses (Split Ingress) ([#403](https://github.com/intershop/helm-charts/issues/403))
* **pwa:** monitoring support for the PWA with Prometheus and Grafana (for development and testing) ([#402](https://github.com/intershop/helm-charts/issues/402))

## Bug Fixes

* **pwa:** repair startup note display
* **pwa:** delay NGINX until PWA SSR is listening
* **pwa:** configurable update strategy with default "RollingUpdate"
* **pwa:** less verbose wget for prefetch job ([#404](https://github.com/intershop/helm-charts/issues/404))

## Documentation

* extended 0.7.0 migration guide and added, updated and unified values configuration examples


<a name="pwa-main-0.7.0"></a>
# [pwa-main-0.7.0](https://github.com/intershop/helm-charts/releases/tag/pwa-main-0.7.0) (2023-03-10)

Compare with previous release: [pwa-main-0.6.0...pwa-main-0.7.0](https://github.com/intershop/helm-charts/compare/pwa-main-0.6.0...pwa-main-0.7.0)

## Features

* add labels on deployment and pod levels
* add additional ingress for domain whitelisting

## Bug Fixes

* change multiChannel and cacheIgnoreParams handling to still support the fallback to the configuration in the project source code

## Documentation

* added description of podLabels and ingresssplit features
* add release version history information, migration guide and development notes
* add Flux v2 configuration example to README.md


<a name="pwa-main-0.6.0"></a>
# [pwa-main-0.6.0](https://github.com/intershop/helm-charts/releases/tag/pwa-main-0.6.0) (2023-02-10)

Compare with previous release: [pwa-main-0.5.0...pwa-main-0.6.0](https://github.com/intershop/helm-charts/compare/pwa-main-0.5.0...pwa-main-0.6.0)

## Features

* support prometheus metrics


<a name="pwa-main-0.5.0"></a>
# [pwa-main-0.5.0](https://github.com/intershop/helm-charts/releases/tag/pwa-main-0.5.0) (2022-12-09)

Compare with previous release: [pwa-main-0.4.0...pwa-main-0.5.0](https://github.com/intershop/helm-charts/compare/pwa-main-0.4.0...pwa-main-0.5.0)

## Features

* support page prefetch ([#178](https://github.com/intershop/helm-charts/issues/178)) ([#186](https://github.com/intershop/helm-charts/issues/186))


<a name="pwa-main-0.4.0"></a>
# [pwa-main-0.4.0](https://github.com/intershop/helm-charts/releases/tag/pwa-main-0.4.0) (2022-11-09)

Compare with previous release: [pwa-main-0.3.1...pwa-main-0.4.0](https://github.com/intershop/helm-charts/compare/pwa-main-0.3.1...pwa-main-0.4.0)

## Features

* support pwa hybrid mode deployment ([#161](https://github.com/intershop/helm-charts/issues/161))


<a name="pwa-main-0.3.1"></a>
# [pwa-main-0.3.1](https://github.com/intershop/helm-charts/releases/tag/pwa-main-0.3.1) (2022-10-20)

Compare with previous release: [pwa-main-0.3.0...pwa-main-0.3.1](https://github.com/intershop/helm-charts/compare/pwa-main-0.3.0...pwa-main-0.3.1)

## Documentation

* remove unnecessary values and namespace option


<a name="pwa-main-0.3.0"></a>
# [pwa-main-0.3.0](https://github.com/intershop/helm-charts/releases/tag/pwa-main-0.3.0) (2022-03-22)

Compare with previous release: [pwa-main-0.2.4...pwa-main-0.3.0](https://github.com/intershop/helm-charts/compare/pwa-main-0.2.4...pwa-main-0.3.0)


<a name="pwa-main-0.2.4"></a>
# [pwa-main-0.2.4](https://github.com/intershop/helm-charts/releases/tag/pwa-main-0.2.4) (2022-03-08)

Compare with previous release: [pwa-main-0.2.3...pwa-main-0.2.4](https://github.com/intershop/helm-charts/compare/pwa-main-0.2.3...pwa-main-0.2.4)

## Features

* add multisite config to PWA helm chart ([#2](https://github.com/intershop/helm-charts/issues/2))
* Adding schema for PWA helm values ([#1](https://github.com/intershop/helm-charts/issues/1))


<a name="pwa-main-0.2.3"></a>
# [pwa-main-0.2.3](https://github.com/intershop/helm-charts/releases/tag/pwa-main-0.2.3) (2022-03-02)

