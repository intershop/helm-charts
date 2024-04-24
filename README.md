# Helm Charts of Intershop`s Service Offering

Ready to launch e.g Intershop PWA on a Kubernetes cluster using Helm.

### Via command line

```bash
$ helm repo add intershop https://intershop.github.io/helm-charts
$ helm repo update
$ helm install my-release intershop/<chart>
```

### Via [Flux](https://fluxcd.io) configuration

```yaml
apiVersion: helm.fluxcd.io/v1
kind: HelmRelease
metadata:
  name: xxx-yyy
  namespace: xxx-yyy

spec:
  rollback:
    enable: true
    force: true
  wait: true
  timeout: 270
  releaseName: xxx-yyy
  chart:
    repository: https://intershop.github.io/helm-charts
    name: <chart>
    version: <chart-version>
  values:
```

In order to contribute, please have a look at our [Contribution Guidelines](./CONTRIBUTING.md)

## License

Copyright &copy; 2024 Intershop Communications AG

[MIT license](./LICENSE).
