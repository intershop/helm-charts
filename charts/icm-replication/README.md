# Helm Chart Intershop Commerce Management - ICM Replication

This is the ICM Replication helm chart

## Prerequisites Details

* helm+kubectl
* Kubernetes 1.14+

## Chart Details

This chart will do the following:

* Deploys two ICM [intershop/icm](../icm) charts, one as edit system and one as live system

## Installing the Chart

### Add the Intershop Helm repository

Before installing Intershop helm charts, you need to add the [Intershop helm repository](https://intershop.github.io/helm-charts) to your helm client

```bash
helm repo add intershop https://intershop.github.io/helm-charts
helm repo update
```

### Install Chart via repository

To install the chart with the release name `icm` execute

```bash
helm install my-release intershop/icm-replication --values=values.yaml --namespace icm-replication
```

### Install Chart via cloned helm-charts repo

```bash
cd charts
helm dependency update icm
helm dependency update icm-replication
helm install my-release ./icm-replication --values=values.yaml --namespace icm-replication
```
