# Migration to 1.0.0

> [!IMPORTANT]
> 1.0.0 is a **major, breaking restructure** of the PWA Helm chart. Almost every value has moved or been renamed.
> Read this guide and adapt your _values_ file before upgrading.

The two tiers are now first-class, explicitly-named sections:

- The **SSR application** (previously configured at the **top level**, resources named `*-pwa-main`) is now under **`app`** (resources named `*-pwa-app`).
- The **nginx reverse proxy** (previously under **`cache`**, resources named `*-pwa-cache`) is now under **`proxy`** (resources named `*-pwa-proxy`).

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
curl -fsSLO https://raw.githubusercontent.com/intershop/helm-charts/pwa-1.0.0/charts/pwa/scripts/migrate-to-1.0.0.py
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

### Common Commands

In the examples below, `MIGRATE` stands for `python migrate-to-1.0.0.py`.
Adjust the path to wherever you saved the script (e.g., `python charts/pwa/scripts/migrate-to-1.0.0.py` from a repo clone).

| Goal                             | Command                                     |
| -------------------------------- | ------------------------------------------- |
| Preview one file (report only)   | `MIGRATE release.yaml`                      |
| Preview with a unified diff      | `MIGRATE release.yaml --show-diff`          |
| Migrate in place (keep a backup) | `MIGRATE release.yaml --write --backup`     |
| Migrate to a new file            | `MIGRATE release.yaml -o .1.0.0.yaml`       |
| Migrate a whole GitOps tree      | `MIGRATE path/to/flux-repo -r --write`      |
| Also schema-check each result    | `MIGRATE release.yaml --write --validate`   |
| Add an IDE `$schema` reference   | `MIGRATE release.yaml --write --add-schema` |

### Good to Know

- **Batch scans are HelmRelease-only.**
  When pointed at a directory (`-r`), the tool migrates **only** `HelmRelease` documents whose chart is `pwa-main`.
  Other charts, other kinds, and bare _values_ files are left untouched, so mixed folder trees are safe.
  A bare _values_ file is migrated **only** when you name it directly on the command line.
- **Kustomize patches are handled.**
  A chart-less `HelmRelease` document (a strategic-merge patch that only carries `spec.values`, e.g., a _version-\*.yaml_ overlay) is migrated too, but **only when its values contain the PWA-specific `cache` or `upstream` block**.
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
- **`--validate`** renders each migrated result against the chart (`helm template`) so that any remaining issue (including a pre-existing typo) surfaces immediately.
  It needs a local copy of the chart: from a repo clone, the default works; if you downloaded only the script, point it at a chart with `--chart-dir` (e.g., `helm pull intershop/pwa --untar` first).
- **`--add-schema`** prepends a `# yaml-language-server: $schema=…` line so that editors with the YAML extension validate the file live as you edit. HelmRelease files get the Flux schema, bare values files the values schema, pinned to `--target-version`.
  Any existing modeline is replaced.
- **Not handled:**
  `spec.valuesFrom` (values stored in an external ConfigMap/Secret) cannot be rewritten by a file tool.
  The run warns if it is present.
  Unknown/custom keys are left unchanged and are handled later by schema validation.

Run `MIGRATE --help` for the full list of options.

## Values Mapping (0.13.0 to 1.0.0)

| 0.13.0                                                                                                                                                                                                                                                                          | 1.0.0                                                                                        |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| `replicaCount`, `image`, `service`, `resources`, `nodeSelector`, `tolerations`, `affinity`, `podAntiAffinity`, `podAnnotations`, `deploymentAnnotations`, `podLabels`, `deploymentLabels`, `metrics`, `livenessProbe`, `readinessProbe`, `updateStrategy` (all top-level = SSR) | The same keys under **`app.*`**                                                              |
| `environment`                                                                                                                                                                                                                                                                   | `app.env`                                                                                    |
| `cache.*` (nginx)                                                                                                                                                                                                                                                               | `proxy.*`                                                                                    |
| `cache.extraEnvVars`                                                                                                                                                                                                                                                            | `proxy.env`                                                                                  |
| `cache.cacheIgnoreParams` / `cache.multiChannel` / `cache.additionalHeaders` / `cache.reset`                                                                                                                                                                                    | `proxy.cacheIgnoreParams` / `proxy.multiChannel` / `proxy.additionalHeaders` / `proxy.reset` |
| `upstream.icmBaseURL`                                                                                                                                                                                                                                                           | `config.icmBaseUrl` (**now required — see below**)                                           |
| `upstream.cdnPrefixURL`                                                                                                                                                                                                                                                         | **Removed**                                                                                  |
| `cache.prefetch`                                                                                                                                                                                                                                                                | **Removed**                                                                                  |
| `calculated`                                                                                                                                                                                                                                                                    | **Removed** (replaced by chart helpers)                                                      |

## `config.icmBaseUrl` Now Required

`upstream.icmBaseURL` shipped a development default (`https://develop.icm.intershop.de`).
This default is gone.
The value moved to `config.icmBaseUrl` and has no default, so an install now fails fast if it is unset instead of silently pointing at a dev backend.

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
  env:
    - name: LOGLEVEL
      value: info

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
  Pods now run non-root, drop all Linux capabilities, and do not auto-mount the API token (`serviceAccount.automount: false`).
  If you relied on root or the token, opt back in explicitly.
- **Probes**:
  The `app` tier now ships liveness/readiness/startup probes based on the SSR image's PM2 scripts.
  The `proxy` tier uses TCP-socket probes.
  Previously both were empty.
- **Image tags** default to `release-<chart appVersion>` (was `latest`), and **pull policy** defaults to `IfNotPresent` (was `Always`) for reproducible deployments.
- **Replica counts** default to `2` per tier (was `1`), and **resource requests/limits** are now set for a production baseline.
- **`updateStrategy`** is now configured per tier (`app.updateStrategy` / `proxy.updateStrategy`) and still defaults to `RollingUpdate`.
- **Ingress class**:
  The default `ingress.className` has changed from `nginx` to `ingress-haproxy`.
  Ingress is still disabled by default (`ingress.enabled: false`), so this affects you only if you enable it and relied on the default.
  To keep the previous behavior, set `ingress.className: nginx` explicitly.

## Resource Name and Label Changes (Breaking for Selectors)

Deployment/service names have changed with the tier renaming:

| 0.13.0                | 1.0.0                 |
| --------------------- | --------------------- |
| `<release>-pwa-main`  | `<release>-pwa-app`   |
| `<release>-pwa-cache` | `<release>-pwa-proxy` |

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
