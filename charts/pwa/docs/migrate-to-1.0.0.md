# Migration to 1.0.0

> [!IMPORTANT]
> 1.0.0 is a **major, breaking restructure** of the PWA Helm chart. Almost every value has moved or been renamed.
> Read this guide and adapt your _values_ file before upgrading.

The two tiers are now first-class, explicitly-named sections:

- The **SSR application** (previously configured at the **top level**, resources named `*-pwa-main`) is now under **`app`** (resources named `*-pwa-app`).
- The **nginx reverse proxy** (previously under **`cache`**, resources named `*-pwa-main-cache`) is now under **`proxy`** (resources named `*-pwa-proxy`).

> [!IMPORTANT]
> **The chart itself has been renamed from `pwa-main` to `pwa`.**
> This is separate from the tier and resource name changes above and affects how you reference the chart:
>
> - **Helm:** `helm install/upgrade <release> intershop/pwa` (was `intershop/pwa-main`)
> - **Flux:** Set `spec.chart.spec.chart: pwa` (was `pwa-main`).
>   The migration script does this for you.
> - **Release tags:** Now `pwa-X.Y.Z` (were `pwa-main-X.Y.Z`)
>
> The old `pwa-main` chart is no longer published.
> Upgrading in place requires switching to the `pwa` chart reference.

> [!TIP]
> You do not have to trace every obsolete key manually.
> If a removed or renamed 0.x value is still present, `helm install`/`upgrade`/`template` fails fast with a message that names the key and its 1.0.0 replacement.
> Fix the reported key and re-run until it succeeds.

## Automated Migration

The repository provides a helper script that applies the mapping below for you while preserving comments and formatting: [`charts/pwa/scripts/migrate-to-1.0.0.py`](../scripts/migrate-to-1.0.0.py).
It is intentionally **not** part of the published chart package, so you must get it from the repository.

### Getting the Script

Download just the file (pin to the release tag or use `main` for the latest):

```bash
curl -fsSLO https://raw.githubusercontent.com/intershop/helm-charts/pwa-1.0.0-memcached.1/charts/pwa/scripts/migrate-to-1.0.0.py
```

Alternatively, clone the repository and run it from there (recommended if you want `--validate`, since a local copy of the chart is then available):

```bash
git clone https://github.com/intershop/helm-charts.git
cd helm-charts
```

Install the requirements (Python 3.14+):

```bash
python -m pip install ruamel.yaml   # required
# the `helm` CLI is needed only for --validate
```

It handles two kinds of input:

- **Flux `HelmRelease` files**: Transforms `spec.values` and updates the chart reference (`pwa-main` to `pwa`, `0.x` to `1.0.0`)
- **Bare values files**: Transforms the whole document (only when the file is named directly; see below).

By default, it runs as a **dry-run** and only reports what it would change.
Nothing is written until you pass `--write` (or `--output-suffix`).

> [!TIP]
> The command to automatically migrate and validate a given `environments` repository (GitOps tree) is:
>
> ```
> python charts/pwa/scripts/migrate-to-1.0.0.py <path-to>/environments/ -r --write --validate --add-schema
> ```
>
> After the migration it is advisable to read through the log to verify everything worked as expected or if there are errors for erroneous configurations.

### Common Commands

In the examples below, `MIGRATE` stands for `python migrate-to-1.0.0.py`.
Adjust the path to wherever you saved the script (e.g., `python charts/pwa/scripts/migrate-to-1.0.0.py` from a repo clone).

| Goal                             | Command                                      |
| -------------------------------- | -------------------------------------------- |
| Preview one file (report only)   | `MIGRATE release.yaml`                       |
| Preview with a unified diff      | `MIGRATE release.yaml --show-diff`           |
| Migrate in place (keep a backup) | `MIGRATE release.yaml --write --backup`      |
| Migrate to a new file            | `MIGRATE release.yaml -o .1.0.0.yaml`        |
| Migrate a whole GitOps tree      | `MIGRATE path/to/flux-repo -r --write`       |
| Also schema-check each result    | `MIGRATE release.yaml --write --validate`    |
| Add an IDE `$schema` reference   | `MIGRATE release.yaml --write --add-schema`  |
| Keep the reset job image as is   | `MIGRATE release.yaml --no-reset-image-vars` |

### Good to Know

- **Batch scans are HelmRelease-only.**
  When pointed at a directory (`-r`), the tool migrates **only** `HelmRelease` documents whose chart is `pwa-main`.
  Other charts, other kinds, and bare _values_ files are left untouched, so mixed folder trees are safe.
  A bare _values_ file is migrated **only** when you name it directly on the command line.

- **Kustomize patches are handled.**
  A chart-less `HelmRelease` document (a strategic-merge patch that only carries `spec.values`, e.g., a _version-\*.yaml_ overlay) is migrated too, but **only when its values contain the PWA-specific `cache`, `upstream`, or `ingresssplit` block**.
  Patches for other charts (which also use generic keys such as `image`) are never touched.
  Its values are rewritten (`image` to `app.image`, `cache.image` to `proxy.image`, etc.) without a chart/version increment.
  Such fragments are skipped by `--validate`/`--add-schema` since a partial _values_ file is not independently schema-valid.

- **Standalone HPAs are folded in (directory mode).**
  When scanning a directory, any standalone `HorizontalPodAutoscaler` manifest is merged into the matching `HelmRelease` as `spec.values.<tier>.autoscaling`, and the now-redundant manifest (plus its `kustomization.yaml` entry) is removed.
  The tier comes from the HPA's `scaleTargetRef` name (`*-pwa-main`/`*-pwa-app` to `app`, `*-pwa-main-cache`/`*-pwa-proxy` to `proxy`) and the release from the name prefix.
  Standard CPU/memory utilization metrics become the `targetCPUUtilizationPercentage`/`targetMemoryUtilizationPercentage` shortcuts.
  Any other metric kind and `behavior` are carried over verbatim.
  Applied only with `--write`.

- **Idempotent.**
  Re-running does nothing to already-migrated files (their chart is now `pwa`).

- **Proxy reset job image as Flux variables.**
  Every migrated `pwa-main` `HelmRelease` gets `proxy.reset.image` set to Flux post-build substitution variables (added, or replacing an existing repository/tag):

  ```yaml
  reset:
    enabled: true
    image:
      repository: ${pwa_proxy_reset_image_repo}
      tag: ${pwa_proxy_reset_image_tag}
      pullPolicy: IfNotPresent
  ```

  An explicit `enabled: false` and an existing `pullPolicy` are kept.
  Make sure both variables are provided via `spec.postBuild.substitute`/`substituteFrom` of the Flux `Kustomization`.
  Bare _values_ files and chart-less patches are not changed.
  Pass `--no-reset-image-vars` to skip this step.

- **`--validate`** renders each migrated result against the chart (`helm template`) so that any remaining issue (including a pre-existing typo) surfaces immediately.
  It needs a local copy of the chart: from a repo clone, the default works; if you downloaded only the script, point it at a chart with `--chart-dir` (e.g., `helm pull intershop/pwa --untar` first).

- **`--add-schema`** prepends a `# yaml-language-server: $schema=…` line so that editors with the YAML extension validate the file live as you edit. HelmRelease files get the Flux schema, bare values files the values schema, pinned to the chart version set on the HelmRelease (`--target-version`, or its default for the release).
  Any existing modeline is replaced.

- **Not handled:**
  `spec.valuesFrom` (values stored in an external ConfigMap/Secret) cannot be rewritten by a file tool.
  The run warns if it is present.
  Unknown/custom keys are left unchanged and are handled later by schema validation.

Run `MIGRATE --help` for the full list of options.

### Memcached Builds

The special `pwa-main` `0.7.1-memcached.N` chart builds are migrated to the matching `pwa` `1.0.0-memcached.N` build, not to the official `1.0.0` chart, which has no Memcached support.

| 0.7.1-memcached.N                                     | 1.0.0-memcached.N                                                                                                    |
| ----------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| `version: 0.7.1-memcached.N`                          | `version: 1.0.0-memcached.1` (default for Memcached builds; override with `--target-version`)                        |
| `cache.memcached.*`                                   | `proxy.memcached.*`; numeric `memoryRequest`/`memoryLimit` and list `args` become strings. An empty block is dropped |
| `cache.extraEnvVars` entry `MEMCACHED_HOSTNAME`       | **Removed** (the chart sets it to the Memcached Service)                                                             |
| `cache.service.type` (also used by Memcached Service) | Not copied: `proxy.memcached.service.type` defaults to `ClusterIP`. The script warns if the type was different       |
| Service `<pwa-main fullname>-memcached`               | Service `<pwa fullname>-memcached`, e.g., `pwa-shop-pwa-main-memcached` becomes `pwa-shop-memcached`                 |

Because the Memcached Service is renamed, references outside the HelmRelease, such as the `memcached.address` of a `prometheus-memcached-exporter` HelmRelease, must change too.
In directory mode, the script searches the scanned files in the same folder as the HelmRelease for the old Service name and rewrites it with `--write`.
If a release name uses Flux variables (e.g., `releaseName: ${namespace}`), the script needs their values to apply the chart's naming rule.
Pass them with `--subst`; the variables are kept in the rewritten names:

```bash
MIGRATE environments/prd/pwa -r --write --validate --subst namespace=pwa-shop-prd
# memcached-exporter.yaml: ${namespace}-pwa-main-memcached:11211 -> ${namespace}-memcached:11211
```

Without `--subst`, the script still searches for the old name, which it can derive without the variable values:

- **No reference found:** a note says that there is nothing to do.
- **Reference found:** each one is listed as `WARNING <file>:<line> … NOT updated`, with an `ACTION` line that names the two possible new names and the exact `--subst` option to pass.
  The run ends with `ACTION REQUIRED: N Memcached Service reference(s) could not be updated`.
  Re-run with `--subst` or change the references manually.

Only files in the HelmRelease's folder are checked, because each deployment folder holds one environment; references elsewhere (other folders, dashboards, alert rules) must be updated manually.

## Values Mapping (0.13.0 to 1.0.0)

| 0.13.0                                                                                                                                                                                                                                                        | 1.0.0                                                                                                                                                               |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `replicaCount`, `image`, `service`, `resources`, `nodeSelector`, `tolerations`, `affinity`, `podAntiAffinity`, `podAnnotations`, `deploymentAnnotations`, `podLabels`, `deploymentLabels`, `metrics`, `livenessProbe`, `readinessProbe` (all top-level = SSR) | The same keys under **`app.*`**                                                                                                                                     |
| `updateStrategy` (top-level, applied to both Deployments)                                                                                                                                                                                                     | `app.updateStrategy` / `proxy.updateStrategy`, both default to `RollingUpdate`. The script drops `RollingUpdate`; any other value is copied to both, with a warning |
| `environment`                                                                                                                                                                                                                                                 | `app.env`                                                                                                                                                           |
| `environment` entries `LOGLEVEL` / `LOGFORMAT` / `METRICS_DETAIL_LEVEL`                                                                                                                                                                                       | `app.logging.level` / `app.logging.format` / `app.metrics.detailLevel`                                                                                              |
| `environment` entry `PORT`                                                                                                                                                                                                                                    | **Removed** (the SSR port is fixed to `4200`)                                                                                                                       |
| `cache.*` (nginx)                                                                                                                                                                                                                                             | `proxy.*`                                                                                                                                                           |
| `cache.extraEnvVars`                                                                                                                                                                                                                                          | `proxy.env`                                                                                                                                                         |
| `cache.extraEnvVars` entries `LOGLEVEL` / `LOGFORMAT`                                                                                                                                                                                                         | `proxy.logging.level` / `proxy.logging.format`                                                                                                                      |
| `cache.cacheIgnoreParams` / `cache.multiChannel` / `cache.additionalHeaders` / `cache.reset`                                                                                                                                                                  | `proxy.cacheIgnoreParams` / `proxy.multiChannel` / `proxy.additionalHeaders` / `proxy.reset`                                                                        |
| `upstream.icmBaseURL`                                                                                                                                                                                                                                         | `config.icmBaseUrl` (dev default kept — see below)                                                                                                                  |
| `upstream.cdnPrefixURL`                                                                                                                                                                                                                                       | **Removed**                                                                                                                                                         |
| `cache.prefetch`                                                                                                                                                                                                                                              | **Removed**                                                                                                                                                         |
| `calculated`                                                                                                                                                                                                                                                  | **Removed** (replaced by chart helpers)                                                                                                                             |

The chart rejects variables it sets or fixes itself in `app.env` or `proxy.env` with a pointer to the value to use instead: always `PORT` (fixed to the image default `4200`), `ICM_BASE_URL`, `LOGLEVEL`, `LOGFORMAT`, `METRICS_DETAIL_LEVEL` (app), and `UPSTREAM_PWA` (proxy); conditionally `ICM_BASE_URL_SSR`, `ALLOWED_HOSTS`, `SSR_HYBRID*`, `HYBRID_FORWARDED_PORT`, `PROMETHEUS`, and the `*_SOURCE` variables when the matching value is set.
The script lifts these entries automatically (also with `--no-lift-env`) and warns about values it cannot map, such as an nginx `LOGLEVEL` other than `error`, `warn`, or `info`.
It also drops `ICM_BASE_URL_SSR` entries in `app.env` or `proxy.env` (for example from `cache.extraEnvVars`), and `ALLOWED_HOSTS` entries in `app.env`, when they equal the resulting `config.icmBaseUrlSsr` or `config.allowedHosts` value. If the value differs, the script keeps the entry and prints a warning.
The 1.0.0 schema requires every `env[].value` to be a string. Helm reads unquoted `on`, `off`, `yes`, `no`, `true`, `false` and numbers as non-strings, so the script warns about such values. Quote them, for example `value: "on"`.

## Migrating from 0.7.0 to 0.12.x

The script supports every `pwa-main` version from **0.7.0** onwards and also converts the layouts that were changed between 0.7.0 and 0.13.0, so older deployments can be migrated in one step.
In addition to the mapping above, it handles the following:

| 0.x (version)                                                                         | 1.0.0                                                                                                                                                            |
| ------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Flat `ingress` (`annotations`, `hosts[].paths`, `tls`) and `ingresssplit` (≤ 0.7.x)   | `ingress.instances.ingress` / `ingress.instances.ingresssplit` (see [Migration to 0.8.0](migrate-to-0.8.0.md)); `paths` are dropped because `/` is always routed |
| `ingress.tls[].secretName` + `hosts` (≤ 0.7.x)                                        | Instance `tlsSecretName` (the secret covering most hosts) plus per-host `tlsSecretName` overrides                                                                |
| `ingress.enabled` unset (≤ 0.7.x default `true`)                                      | `ingress.enabled: true` set explicitly                                                                                                                           |
| `ingress.enabled: true` without `className` (0.x default `nginx`)                     | `ingress.className: nginx` set explicitly (the 1.0.0 default is `ingress-haproxy`)                                                                               |
| `hybrid.backend.service`/`port` (≤ 0.9.x), `hybrid.icmInternalURL` (0.10.0 to 0.13.0) | `config.icmBaseUrlSsr`, only when `hybrid.enabled`; for `hybrid.backend` the URL is derived from the Flux release name as the 0.x chart did                      |
| `cache.reset.image: <repository>:<tag>` (0.11.0)                                      | `proxy.reset.image.repository` / `proxy.reset.image.tag`                                                                                                         |
| `cache.init.enabled: false` (0.9.3 to 0.11.x)                                         | `proxy.reset.enabled: false` (see [Migration to 0.12.0](migrate-to-0.12.0.md))                                                                                   |
| `cache.nameOverride` / `cache.fullnameOverride`                                       | **Removed**                                                                                                                                                      |
| `cache.enabled` (ignored since 0.7.0, the proxy is always deployed)                   | **Removed**                                                                                                                                                      |

The script warns about everything it cannot convert one-to-one, for example custom ingress paths, differing `ingress`/`ingresssplit` class names, or hosts without TLS when other hosts of the same instance use TLS.

## `config.icmBaseUrl`

`upstream.icmBaseURL` was renamed to `config.icmBaseUrl`.
It keeps the same development default (`https://develop.icm.intershop.de`), so override it with your own ICM backend for any real deployment.

Before:

```yaml
upstream:
  icmBaseURL: https://icm.example.com
```

After:

```yaml
config:
  icmBaseUrl: https://icm.example.com
```

## Renamed Tiers

Before (0.13.0):

```yaml
replicaCount: 2
image:
  repository: intershophub/intershop-pwa-ssr
environment:
  - name: LOGLEVEL
    value: info

cache:
  replicaCount: 2
  multiChannel: |
    .+:
      - baseHref: /b2c
        channel: inSPIRED-inTRONICS-Site
  extraEnvVars:
    - name: CACHE
      value: 'on'
```

After (1.0.0):

```yaml
app:
  replicaCount: 2
  image:
    repository: intershophub/intershop-pwa-ssr
  logging:
    level: info

proxy:
  replicaCount: 2
  multiChannel: |
    .+:
      - baseHref: /b2c
        channel: inSPIRED-inTRONICS-Site
  env:
    - name: CACHE
      value: 'on'
```

## Removed Values

| Removed                                 | What to do                                                                       |
| --------------------------------------- | -------------------------------------------------------------------------------- |
| `upstream.cdnPrefixURL`                 | Remove it. Serve assets via your ingress/CDN in front of the proxy instead.      |
| `cache.prefetch` (and the prefetch job) | Remove it. Cache warm-up is no longer performed by the chart.                    |
| `calculated`                            | Remove it. Metrics/monitoring wiring is now handled internally by chart helpers. |

## Changed Defaults & Behavior

These changes affect how a **default** install behaves, even if you do not change the values:

- **Secure-by-default**:
  The SSR application and nginx workers run as non-root users. Containers drop capabilities they do not need. The proxy receives only the capabilities it requires.
  The proxy cache clearer reads the PWA app Endpoints resource. The chart grants `get` access through a namespaced `Role` and `RoleBinding`.
  The workload `ServiceAccount` mounts a token for this request.
  Set `serviceAccount.name` to use a named `ServiceAccount`. Set `serviceAccount.create: false` to use an externally managed account.
  Create the required `Role` and `RoleBinding` for externally managed accounts. Set `serviceAccount.automount: false` to disable token mounting.
- **Probes**:
  The `app` tier now ships liveness/readiness/startup probes based on the SSR image's PM2 scripts.
  The `proxy` tier uses TCP-socket probes.
  Previously both were empty.
- **Image tags** default to `release-<chart appVersion>` (was `latest`), and **pull policy** defaults to `IfNotPresent` (was `Always`) for reproducible deployments.
- **Proxy reset job image**:
  `proxy.reset.image` defaults to the public `bitnami/kubectl:latest` image (was `ishcp.azurecr.io/ishops/cronjob-utils:1`), so the job no longer requires access to the Intershop registry.
  To keep the previous image, set `proxy.reset.image.repository` and `proxy.reset.image.tag` explicitly.
- **Replica counts** default to `2` per tier (was `1`), and **resource requests/limits** are now set for a production baseline.
- **`updateStrategy`** is now configured per tier (`app.updateStrategy` / `proxy.updateStrategy`) and still defaults to `RollingUpdate`.
- **Proxy access logs**:
  `proxy.logging.level` defaults to `info`, so nginx logs all requests (the 0.x image default `error` logged 5xx responses only).
  To keep the previous behavior, set `proxy.logging.level: error` explicitly.
- **Ingress class**:
  The default `ingress.className` has changed from `nginx` to `ingress-haproxy`.
  Ingress is still disabled by default (`ingress.enabled: false`), so this affects you only if you enable it and relied on the default.
  To keep the previous behavior, set `ingress.className: nginx` explicitly.
- **Custom pod anti-affinity**:
  A custom `<tier>.affinity.podAntiAffinity` (`affinity.podAntiAffinity` or `cache.affinity.podAntiAffinity` in 0.x) can no longer be combined with the built-in `<tier>.podAntiAffinity`, which is enabled by default.
  In 0.13.x, the chart rendered both, and the chart's rule silently replaced yours. 1.0.0 fails the render with an error instead.
  To keep your custom rules, set `<tier>.podAntiAffinity.enabled: false`.
  To use the chart's rule, remove `<tier>.affinity.podAntiAffinity` and configure `<tier>.podAntiAffinity.required`.
  Other affinity types such as `nodeAffinity` are still merged with the built-in rule.
  The migration script warns about this combination but does not change it.

## Resource Name and Label Changes (Breaking for Selectors)

Deployment/service names have changed with the tier renaming:

| 0.13.0                     | 1.0.0                 |
| -------------------------- | --------------------- |
| `<release>-pwa-main`       | `<release>-pwa-app`   |
| `<release>-pwa-main-cache` | `<release>-pwa-proxy` |

All names stay within the 63-character Kubernetes limit: for long release names or `fullnameOverride` values, the `<release>-pwa` part is shortened so that the suffix (`-app`, `-proxy`, `-app-metrics`, `-proxy-reset-job`, …) is always kept in full.

> [!IMPORTANT]
> Anything that selects these resources **by name** (monitoring dashboards, `NetworkPolicy`, `ServiceMonitor`, external scripts) must be updated.

## Verifying Your Upgrade

Preview the change before applying (requires the `helm-diff` plugin):

```bash
helm diff upgrade <release> intershop/pwa -f your-values.yaml
```

After upgrading, confirm the new resource names exist:

```bash
kubectl get deploy -l app.kubernetes.io/instance=<release>
# expect <release>-pwa-app and <release>-pwa-proxy
```
