# Helm Chart Intershop Commerce Management - ICM Replication

This is the ICM Replication Helm chart.

## Prerequisites Details

* Helm
* kubectl
* Kubernetes 1.14+

## Chart Details

This chart will do the following:

* Deploys two ICM [intershop/icm](../icm) charts, one as edit system and one as live system

## Installing the Chart

### Add the Intershop Helm Repository

Before installing Intershop Helm charts, add the [Intershop helm-charts repository](https://intershop.github.io/helm-charts) to your helm client.

```bash
helm repo add intershop https://intershop.github.io/helm-charts
helm repo update
```

### Install Chart via Repository

To install the chart with the release name `icm`, execute:

```bash
helm install my-release intershop/icm-replication --values=values.yaml --namespace icm-replication
```

### Install Chart via Cloned helm-charts Repository

```bash
cd charts
helm dependency update icm
helm dependency update icm-replication
helm install my-release ./icm-replication --values=values.yaml --namespace icm-replication
```

## Testing ICM-Replication

This Helm chart also allows you to execute Intershop HtmlUnit tests via a testrunner.

### Execute Locally
For the local test execution, there are already preconfigured values-files orchestrated by a bash script.
Follow these steps to execute a test:

1. Ensure each included chart is up-to-date:
```bash
helm dependency update ../icm-as
helm dependency update ../icm
helm dependency update .
```
2. Create needed k8s secrets for icm-web and icm-as (e.g., `kubectl create secret docker-registry dockerhub --docker-username=<your username> --docker-password=<your password> --docker-email=<your email>`).
3. Run: `./start-test-local.sh` and follow the instructions.
