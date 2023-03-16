# Migration to 0.7.0

## Removed Support of `upstream.icm` Configuration

The already deprecated `upstream.icm` configuration property was removed completely.
Migrate any Helm chart values file to use only `upstream.icmBaseURL` to configure the ICM in use.

Old:

```yaml
upstream:
  icm: https://pwa-ish-demo.test.intershop.com
```

New:

```yaml
upstream:
  icmBaseURL: https://pwa-ish-demo.test.intershop.com
```

## Removed Obsolete `cache.enabled` Configuration

Evaluation of the `cache.enabled` configuration was completely removed since the deployment of the `cache` container was never optional for production environments.
This is due to the fact that the `cache` container is actually an `nginx` container and handles not only caching but also multi-channel/multi-site configuration, device detection, compression and sitemap access.

For this reason, there should be no Helm values configurations that actually disable the `cache` container, so no migration efforts are required.
All `cache.enabled` configurations can be removed since they are no longer evaluated.

If actual features of the `cache` container should be disabled, there are several environment configurations available that can be configured via `cache.extraEnvVars` (see the Intershop PWA documentation regarding the [nginx docker image](https://github.com/intershop/intershop-pwa/blob/develop/docs/guides/nginx-startup.md#other)).

## Removed Support for `cache.channels` Configuration

Since the functionality to configure multiple channels for the use with one PWA deployment has been reworked in PWA version 0.25.0, the previous way to configure it via `channels:{}` configuration was no longer working and is now removed completely.

Old multi channels configuration:

```yaml
cache:
  channels:
    PWA_1_SUBDOMAIN: b2b
    PWA_1_CHANNEL: inSPIRED-inTRONICS_Business-Site
    PWA_2_SUBDOMAIN: b2c
    PWA_2_CHANNEL: inSPIRED-inTRONICS-Site
```

Therefore, for deployments that require multi-channel handling with an Intershop PWA version prior to 0.25.0 the Helm Chart version 0.7.0 cannot be used.

Current Helm chart configurations should use the `multiChannel` object to configure multi-channel/multi-site deployments.

> :warning: **NOTE:** Besides the multiple channel configuration for PWA versions prior to 0.25.0 the `cache.channels` configuration was miss used with more current PWA versions to set environment variables for the NGINX container.
> To set the environment variables the PWA Helm Chart version 0.2.4 introduced the `cache.extraEnvVars` configuration.
> This configuration is now with the PWA Helm Chart 0.7.0 the only option to set environment variables for the NGINX/cache container.

Old:

```yaml
cache:
  channels:
    CACHE: "off"
    DEBUG: "off"
    OVERRIDE_IDENTITY_PROVIDERS: ...
    MULTI_CHANNEL: ...
```

New:

```yaml
cache:
  extraEnvVars:
    - name: CACHE
      value: "off"
    - name: DEBUG
      value: "off"
    - name: OVERRIDE_IDENTITY_PROVIDERS
      value: ...
    - name: MULTI_CHANNEL
      value: ...
```

## Support for `multi-channel.yaml` and `caching-ignore-params.yaml` Source Code Fallbacks

The `multiChannel` and `cacheIgnoreParams` handling has been changed to still support the fallback to the configuration in the project source code `multi-channel.yaml` and `caching-ignore-params.yaml` files.
This change restores compatibility with PWA Helm chart version 0.2.3 configurations that used the fallbacks but no multi-channel configuration via Helm chart.

So be aware that when using Helm chart version 0.7.0 the `multiChannel` and `cacheIgnoreParams` of the according files in the source code will be used if nothing else is configured in the Helm chart values file.
