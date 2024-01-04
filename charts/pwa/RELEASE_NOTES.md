
<a name="pwa-0.8.0"></a>
## pwa-0.8.0

> 2024-01-04

### Chore

* bump versions of pwa:minor
* fix .bumpversion.toml format to work without errors
* integrate main to develop/pwa ([#418](https://github.com/intershop/helm-charts/issues/418))
* documentation cleanup/restructuring + release information
* use schema for validation
* add bumpversion toml to pw chart ([#476](https://github.com/intershop/helm-charts/issues/476))
* further release process automation ([#462](https://github.com/intershop/helm-charts/issues/462))
* remove deprecated 'upstream.icm' configuration property - only 'upstream.icmBaseURL' is supported now
* remove 'cache.enabled' configuration since the nginx deployment was never optional
* remove obsolete 'channels:{}' functionality
* support alpha releases
* change ICM upstream example
* enable automatic install on ci (compat testing)
* Update README for better clarity

### Deps

* bump prefetch job dependency customized alpine image to alpine 3.18 ([#326](https://github.com/intershop/helm-charts/issues/326))

### Docs

* extended 0.7.0 migration guide and added, updated and unified values configuration examples
* added description of podLabels and ingresssplit features
* add release version history information, migration guide and development notes
* add Flux v2 configuration example to README.md
* remove unnecessary values and namespace option

### Feat

* add labels on deployment and pod levels
* add additional ingress for domain whitelisting
* support prometheus metrics
* support page prefetch ([#178](https://github.com/intershop/helm-charts/issues/178)) ([#186](https://github.com/intershop/helm-charts/issues/186))
* support pwa hybrid mode deployment ([#161](https://github.com/intershop/helm-charts/issues/161))
* add multisite config to PWA helm chart ([#2](https://github.com/intershop/helm-charts/issues/2))
* Adding schema for PWA helm values ([#1](https://github.com/intershop/helm-charts/issues/1))
* **pwa:** option to add additional headers to NGINX results ([#489](https://github.com/intershop/helm-charts/issues/489))
* **pwa:** shared Redis cache config and flush job ([#401](https://github.com/intershop/helm-charts/issues/401))
* **pwa:** new format of declaring (multiple) Ingresses (Split Ingress) ([#403](https://github.com/intershop/helm-charts/issues/403))
* **pwa:** monitoring support for the PWA with Prometheus and Grafana (for development and testing) ([#402](https://github.com/intershop/helm-charts/issues/402))

### Fix

* change multiChannel and cacheIgnoreParams handling to still support the fallback to the configuration in the project source code
* **pwa:** repair startup note display
* **pwa:** delay NGINX until PWA SSR is listening
* **pwa:** configurable update strategy with default "RollingUpdate"
* **pwa:** less verbose wget for prefetch job ([#404](https://github.com/intershop/helm-charts/issues/404))

