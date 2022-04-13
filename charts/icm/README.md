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
$ helm repo add intershop https://intershop.github.io/helm-charts
$ helm repo update
```

### Install Chart
To install the chart with the release name `icm`
```bash
$ helm install my-release intershop/icm --values=values.yaml --namespace icm
```
