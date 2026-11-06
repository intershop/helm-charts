# PWA Chart Unit Tests

The `*_test.yaml` files in this folder are [helm-unittest](https://github.com/helm-unittest/helm-unittest) suites.
They render the chart templates with given values and assert on the result; no cluster is needed.
This folder is excluded from the packaged chart (see `../.helmignore`).

## Running

Install the plugin once (the version CI uses):

```bash
helm plugin install https://github.com/helm-unittest/helm-unittest.git --version=v1.1.2 --verify=false
```

Run all suites, or a single suite, from the repository root:

```bash
helm unittest charts/pwa
helm unittest -f 'tests/labels_test.yaml' charts/pwa
```

CI runs all suites on every pull request that touches the chart, and `fail-fast_test.yaml` again on the minimum supported Helm version (see `.github/workflows/lint-test_pwa-unittest.yml`).

## Suite Layout

Suites are organized **by concern**, not by template.
A suite lists every template its concern touches and covers both tiers (`app` and `proxy`) where the concern applies to both.

| Suite                        | Concern                                                                                        |
| ---------------------------- | ---------------------------------------------------------------------------------------------- |
| `default-values_test.yaml`   | The chart renders both tiers with the default `values.yaml`                                    |
| `fail-fast_test.yaml`        | Schema typo guards and invalid values (also run on the minimum Helm version)                   |
| `deprecations_test.yaml`     | Targeted errors for values removed or renamed in 1.0.0                                         |
| `managed-env_test.yaml`      | Chart-managed env vars are rejected in `app.env`/`proxy.env`; user entries are appended        |
| `naming_test.yaml`           | Resource names, `nameOverride`/`fullnameOverride`, the 63-char limit, ServiceAccount selection |
| `labels_test.yaml`           | The recommended label set on every resource, including the version label                       |
| `image_test.yaml`            | Container image repository, tag, and pull policy                                               |
| `passthrough_test.yaml`      | Values copied verbatim (`nodeSelector`, `tolerations`, pod/Deployment labels and annotations)  |
| `security-context_test.yaml` | Pod/container security contexts, overrides, and the ServiceAccount's permissions and token     |
| `probes_test.yaml`           | Startup/liveness/readiness probes                                                              |
| `anti-affinity_test.yaml`    | Pod anti-affinity and its merge with custom `affinity`                                         |
| `hpa_test.yaml`              | HorizontalPodAutoscalers and the Deployment `replicas` interaction                             |
| `wiring_test.yaml`           | Proxy-to-app upstream and shared `config.*` env injection                                      |
| `hybrid_test.yaml`           | Hybrid Approach env vars                                                                       |
| `logging_test.yaml`          | Log level and format per tier                                                                  |
| `metrics_test.yaml`          | Opt-in Prometheus metrics: ports, env, and headless metrics Services                           |
| `monitoring_test.yaml`       | The dev-only Prometheus/Grafana stack and its scrape wiring                                    |
| `ingress_test.yaml`          | Ingress instances, hosts, and TLS                                                              |
| `proxy-config_test.yaml`     | The proxy ConfigMap (multi-channel, cache-ignore, headers) and its mounts                      |
| `cache-volume_test.yaml`     | The writable nginx cache volume                                                                |
| `proxy-reset-job_test.yaml`  | The post-upgrade proxy reset hook and its RBAC                                                 |

Add a test to the suite that owns its concern; create a new suite only for a new concern.
Some resources are covered by several suites, each for its own concern.
For example, the ServiceAccount's **name** belongs in `naming_test.yaml`, its **labels** in `labels_test.yaml`, and its **permissions and token** in `security-context_test.yaml`.

## Conventions

- Use `release.name: pwa`, so the expected names are `pwa-app` and `pwa-proxy`.
- Describe the expected behavior in `it:`, e.g. `proxy omits affinity entirely when disabled`.
- Test the default and at least one override, and assert that nothing is rendered when a feature is off.
- For values that exist per tier, test both tiers and check that one tier's values do not leak into the other.
- Assert failures with `failedTemplate.errorPattern` on the chart's message, so a schema error cannot pass for the expected one.
- Use `equal` for exact values. With `contains`/`notContains` on a partial list entry, add `any: true`; otherwise the whole entry must match.
- Use `documentSelector` (e.g. on `kind`) instead of `documentIndex` when a template renders several kinds.
- Pin `chart.appVersion` in a suite whose assertions depend on it, so app version bumps do not break the tests.
- When adding a test for a fix, check that it fails without the fix.

## Related Tests

- `../ci/*-values.yaml`: install scenarios that `ct install` deploys to a kind cluster in CI (`.github/workflows/lint-test_pwa-integrationtest.yml`).
- `../scripts/tests/`: pytest suite for the 0.x to 1.0.0 migration script (`python -m pytest -q` from that folder).
