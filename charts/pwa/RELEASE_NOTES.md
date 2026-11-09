
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
