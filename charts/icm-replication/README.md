# Helm Chart Intershop Commerce Management - ICM Replication

This is the ICM Replication helm chart

## Prerequisites Details

* helm+kubectl
* Kubernetes 1.14+

## Chart Details

This chart will do the following:

* Deploys two ICM [intershop/icm](../icm) charts, one as Edit- and one as Live-System

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

## Testing ICM-Replication

This helm chart also allows you to execute intershop htmlunit tests via a testrunner.

### Execute locally
For the local test execution there are already preconfigured values-files orchestrated by a bash script.
Follow these steps to execute a test:

1. Be sure that each included chart is up-to-date:
```bash
helm dependency update ../icm-as
helm dependency update ../icm
helm dependency update .
```
2. Create needed k8s secrets for icm-web and icm-as (e.g. `kubectl create secret docker-registry dockerhub --docker-username=<your username> --docker-password=<your password> --docker-email=<your email>`)
3. run: `./start-test-local.sh` and follow the instructions
