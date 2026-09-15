# Intershop Helm Charts

Helm charts to deploy Intershop's service offering — the Intershop Commerce Management (ICM)
suite, Intershop Order Management (IOM) and the Intershop Progressive Web App (PWA) — on a
Kubernetes cluster.

Charts are published to the Helm repository at **https://intershop.github.io/helm-charts**.

## Available charts

| Chart      | Description                                                                                                 |
| ---------- | ----------------------------------------------------------------------------------------------------------- |
| `icm`      | Intershop Commerce Management — umbrella chart bundling the app server, web adapter and supporting services |
| `icm-as`   | ICM application server                                                                                      |
| `icm-web`  | Web Adapter and Web Adapter Agent                                                                           |
| `icm-job`  | ICM job controller / operator                                                                               |
| `iom`      | Intershop Order Management                                                                                  |
| `pwa-main` | Intershop Progressive Web App                                                                               |

> The `*-test` charts (`icm-test`, `icm-job-test`, `icm-replication-test`) support automated
> testing and are not intended for production use.

Each chart ships its own `README` and `values.yaml` documenting all configurable values.

## Deployment via command line

```bash
$ helm repo add intershop https://intershop.github.io/helm-charts
$ helm repo update
$ helm install my-release intershop/<chart>
```

## Deployment via [Flux](https://fluxcd.io)

```yaml
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: ${namespace}
  namespace: ${namespace}
spec:
  chart:
    spec:
      name: <chart>
      version: <chart-version>
      sourceRef:
        kind: HelmRepository
        name: ish-helm-charts
        namespace: flux-system
  releaseName: ${namespace}
  targetNamespace: ${namespace}
  interval: 1m0s
  # Helm Values - to be adapted by the dev team
  values:
```

## Contributing & releasing

- [Contribution Guidelines](./CONTRIBUTING.md) — branching model and commit conventions
- [Releasing](./RELEASING.md) — how versions, changelogs and releases are produced

## License

Copyright &copy; 2026 Intershop Communications AG

[MIT license](./LICENSE).
