# Migration to 0.12.0

## BREAKING: Changed structure of cache reset configuration

Unfortunately the `cache.reset.image` section didn't follow the regular pattern for image references - image repository and tag were "squashed" into a single value and it was not possible to change the pull policy of the image. This has been rectified, the reference can now be configured via `repository`, `tag` and `pullPolicy`.

## Removal of Init Container

After introduction of the new "cache reset" functionality in 0.11.0 the old init container has become obsolete. The init container has been removed from the manifests, the `cache.init` section has been removed from the helm values and `cache.reset.enabled` is now set to `true` by default. Enabling this by default is a direct replacement of `cache.init.enabled=true` which was the default prior to it's removal.

If you previously set `cache.init.enabled=false` and don't need the cache reset functionality just set `cache.reset.enabled=false`.
