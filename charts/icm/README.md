# Helm Chart Intershop Commerce Management

Installs the ICM umbrella chart including application server, webadapter and webadapter agent.

## TL;DR
Via command line:
```bash
$ helm repo add intershop https://intershop.github.io/helm-charts
$ helm repo update
$ helm install my-release intershop/icm --values=values.yaml --namespace icm
```
