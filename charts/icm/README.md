# Helm Chart Intershop Commerce Management

Installs the ICM umbrella chart containing the [application server](../icm-as/README.md)-, [webadapter and webadapter agent](../icm-web/README.md)-chart.

## TL;DR
Via command line:
```bash
$ helm repo add intershop https://intershop.github.io/helm-charts
$ helm repo update
$ helm install my-release intershop/icm --values=values.yaml --namespace icm
```
