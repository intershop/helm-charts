# Why Upgrade to PWA Helm Chart 1.0.0

PWA Helm Chart 1.0.0 is the first stable release of the chart.
It focuses less on new features and more on maturity: secure and production-ready defaults, a clearer configuration structure, and early detection of configuration errors.
This page summarizes what you gain by upgrading.
For the upgrade steps, see the [Migration to 1.0.0](migrate-to-1.0.0.md) guide.

> [!TIP]
> **In short:** PWA Helm Chart 1.0.0 is secure and production-ready by default.
> Its configuration is clearly split into an `app` and a `proxy` tier, autoscaling is built in, and configuration errors are reported before anything is deployed.
> A migration script automates most of the upgrade.

## Production-Ready Defaults

|                         | 0.x                                                            | 1.0.0                                                                                              |
| ----------------------- | -------------------------------------------------------------- | -------------------------------------------------------------------------------------------------- |
| Replicas                | 1                                                              | 2 per tier (app and proxy)                                                                         |
| Resources               | `{}` (no requests or limits)                                   | Requests and limits set                                                                            |
| Probes                  | None                                                           | Liveness, readiness, and startup probes for the app (PM2 process health); TCP probes for the proxy |
| Image tag / pull policy | `latest` / `Always`                                            | `release-<chart appVersion>` / `IfNotPresent`                                                      |
| ICM base URL            | Defaults to a development backend (_develop.icm.intershop.de_) | Required; the installation fails with a clear message if it is not set                             |

**Benefits:** The default installation is production-ready without additional tuning.
Deployments are reproducible because image tags are pinned to the chart's `appVersion` instead of `latest`.
A production system can no longer end up connected to a development backend by accident.

## Secure by Default

- The shared container baseline drops all Linux capabilities (`drop: ALL`) and disallows privilege escalation.
- The app container runs as the unprivileged user `65534`.
- The nginx master process of the proxy still runs as root, but it only restores the capabilities that nginx needs (`CHOWN`, `SETGID`, `SETUID`, `DAC_OVERRIDE`).
  The nginx worker processes run as an unprivileged user.

**Benefits:** You have a smaller attack surface and fewer findings in security reviews and policy checks.

## Clear Configuration Structure

- The configuration is split into two explicitly named tiers: `app` (Angular SSR) and `proxy` (nginx).
  In 0.x, the SSR configuration was at the top level and the nginx configuration was under `cache`.
- Resource names match the tiers: `<release>-pwa-app` and `<release>-pwa-proxy`.
- Both tiers use the same keys, for example, `app.env` and `proxy.env` (previously `environment` and `cache.extraEnvVars`).
- The only value you must set is `config.icmBaseUrl`.
- The [parameter reference](../README.md#parameters) is generated from _values.yaml_ and always matches the chart version.

**Benefits:** Values files are easier to read, review, and maintain.

## Built-In Autoscaling

- Each tier can be scaled independently with a HorizontalPodAutoscaler (`app.autoscaling` and `proxy.autoscaling`).
- CPU and memory targets cover the common case.
  For advanced cases, `metrics` and `behavior` are passed to the `autoscaling/v2` API unchanged.
- When autoscaling is enabled, the deployment omits `spec.replicas`, so Helm upgrades do not interfere with the autoscaler.
- If you maintain standalone HPA manifests next to your `HelmRelease`, the migration script can move them into the chart values.

See [Autoscaling (HPA)](../README.md#autoscaling-hpa) for examples.

**Benefits:** Scaling is configured and versioned together with the release instead of in separate manifests.

## Early Detection of Configuration Errors

- A strict [values schema](../values.schema.json) rejects typos and unknown keys during `helm install`, `helm upgrade`, and `helm template`.
- If an obsolete 0.x key is still set, rendering stops with a message that names the key and its 1.0.0 replacement.
- The chart declares its supported Kubernetes version (`>= 1.23`), so Helm refuses to install it on older clusters.
- Editors with YAML language support can validate _values_ files and Flux `HelmRelease` resources while you type.
  See [Validation](../README.md#validation).

**Benefits:** Mistakes surface when the chart is rendered, not as a failing or misbehaving deployment.

## Tested and Verifiable

- The helm-unittest suites cover security contexts, probes, autoscaling, ingress, labels, naming, and the Hybrid Approach.
- The CI validates the chart against the current stable Helm 4 release on every change.
- After an installation or upgrade, run `helm test <release>` to verify that the proxy service reaches a serving Pod.

**Benefits:** More confidence in upgrades and a quick smoke test for your own deployments.

## Largely Automated Migration

- The [migration script](../scripts/migrate-to-1.0.0.py) rewrites values files and Flux `HelmRelease` resources, including the chart reference.
- It runs as a dry run by default, preserves comments and formatting, and can show a diff.
- It can process entire GitOps directories, including Kustomize patches.
- With `--validate`, it renders each result against the chart, so remaining issues show up immediately.
- Running it again on already migrated files changes nothing.

See [Migration to 1.0.0](migrate-to-1.0.0.md) for details.

## Local Development

The production-oriented defaults (two replicas per tier, resource requests, Pod anti-affinity) may not fit a single-node cluster.
The [non-production values template](../values-nonproduction.yaml.template) reduces them so that the chart runs on kind, minikube, k3d, or Docker Desktop.
See [Non-Production Deployment](../README.md#non-production-deployment).

## Before You Upgrade

1.0.0 is a breaking release.
Plan the upgrade with the following points in mind:

- The chart is renamed from `pwa-main` to `pwa`.
  Update your Helm or Flux chart reference.
- Almost all values have moved or been renamed.
- `config.icmBaseUrl` is required.
- Resource names change from `*-pwa-main` / `*-pwa-cache` to `*-pwa-app` / `*-pwa-proxy`.
  Update dashboards, `NetworkPolicy` and `ServiceMonitor` resources, and scripts that select these resources by name.
- The default `ingress.className` is now `ingress-haproxy` instead of `nginx`.
  If you enable ingress and rely on the old default, set `ingress.className: nginx` explicitly.
- If you use the shared Redis cache, the prefetch job, or `upstream.cdnPrefixURL`, plan a replacement before upgrading or open an issue to signal that this feature is actually used and needs to be re-introduced to the Helm chart.
- The migration script cannot rewrite values provided via `spec.valuesFrom` (ConfigMaps or Secrets).
  Migrate those values manually.

Follow the [Migration to 1.0.0](migrate-to-1.0.0.md) guide and preview the changes with `helm diff upgrade` before applying them.
