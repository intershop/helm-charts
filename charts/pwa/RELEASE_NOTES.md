
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
