# Helm Chart Intershop Commerce Management - ICM

This is the ICM helm chart

## Prerequisites Details

* helm+kubectl
* Kubernetes 1.14+
* Valid license file

## Chart Details

This chart will do the following:

* Deploy an ICM Application Server using the [intershop/icm-as](../icm-as) chart
* Deploy an ICM Web Adapter and Web Adapter Agent using the [intershop/icm-web](../icm-web) chart

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
helm install my-release intershop/icm --values=values.yaml --namespace icm
```

### Install Chart via cloned helm-charts repo

```bash
cd charts
helm dependency update icm
helm install my-release ./icm --values=values.yaml --namespace icm
```

## Testing the Chart

### helm-unit

There are helm-unit tests to support development and secure several functionality

```bash
helm unittest --helm3  --output-file unit.xml --output-type JUnit charts/icm
```

### ct lint & install

```bash
docker run -it --network host --workdir=/data --volume <my kube config>:/root/.kube/config:ro --volume
$(pwd):/data quay.io/helmpack/chart-testing:v3.5.0 ct lint --config ct_icm.yaml
```

## Testing ICM

This helm chart also allows you to execute intershop htmlunit tests via a testrunner.

### Execute locally
For the local test execution there are already preconfigured values-files orchestrated by a bash script.
Follow these steps to execute a test:

1. add a "intershop-license" k8s secret with a valid intershop license (e.g. `kubectl create secret generic intershop-license --from-file=license.xml`)
2. add k8s secrets for icm-web and icm-as (e.g. `kubectl create secret docker-registry dockerhub --docker-username=<your username> --docker-password=<your password> --docker-email=<your email>`)
3. run: `./start-test-local.sh` and follow the instructions