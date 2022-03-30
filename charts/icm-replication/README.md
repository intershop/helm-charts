# Helm Chart Intershop Commerce Management - Replication

Installs the ICM replication umbrella chart containing two [ICM umbrella charts](../icm/README.md) for live- and edit-system each one including it's own application server, webadapter and webadapter agent.

## TL;DR
Via command line:
```bash
$ helm repo add intershop https://intershop.github.io/helm-charts
$ helm repo update
$ helm install my-release intershop/icm-replication --values=values.yaml --namespace icm-replication
```
