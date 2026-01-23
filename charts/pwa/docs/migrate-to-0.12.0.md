# Migration to 0.12.0

## Changed Structure of Cache Reset Image Configuration

The `cache.reset.image` section did not follow the regular pattern for image references - image repository and tag were "squashed" into a single value and it was not possible to change the pull policy of the image.
This has been rectified.
The reference can now be configured via `repository`, `tag`, and `pullPolicy`.

```yaml
cache:
  reset:
    enabled: true
    image:
      repository: bitnami/kubectl
      tag: latest
      pullPolicy: Always
```

## Removed Cache Init Container

After introducing the new _Cache Reset_ functionality in 0.11.0, the old _Cache Init_ container became obsolete.
The init container was removed from the manifests, the `cache.init` section was removed from the helm values, and `cache.reset.enabled` is now set to `true` by default.
Enabling this by default directly replaces `cache.init.enabled=true`, which was the default prior to its removal.

If you previously set `cache.init.enabled=false` and do not need the cache reset functionality, now set `cache.reset.enabled=false`.
