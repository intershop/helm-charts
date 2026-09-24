
<a name="pwa-1.0.0"></a>
# [pwa-1.0.0](https://github.com/intershop/helm-charts/releases/tag/pwa-1.0.0) (2026-09-16)

Compare with previous release: [pwa-main-0.13.0...pwa-1.0.0](https://github.com/intershop/helm-charts/compare/pwa-main-0.13.0...pwa-1.0.0)

## Notes

**BREAKING:** 1.0.0 is a major restructure — almost every value has moved or been renamed. Read the [Migration to 1.0.0](https://github.com/intershop/helm-charts/blob/pwa-1.0.0/charts/pwa/docs/migrate-to-1.0.0.md) guide before upgrading.

## Features

* introduce PWA Helm Chart 1.0.0


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

