# Helm Chart Intershop Commerce Management - Web Adapter and Web Adapter Agent

Installs the ICM web adapter and web adapter agent independently.

## Prerequisites Details

* helm+kubectl
* Kubernetes 1.14+

## Chart Details

This chart will do the following:

* Deploy an ICM Web Adapter and Web Adapter Agent

## Installing the Chart

### Docker pull secret

Create a secret for a docker registry where the images are coming from. The name of the secret must be equal to the configured secrets under `agent.image.secret` and `webadapter.image.secret` within the application deployment. By default the secret name is `dockerhub`.

```bash
kubectl create secret docker-registry <yourDockerRegistryName> --docker-server=<yourDockerRegistryServer> --docker-username=<yourUsername> --docker-password=<yourPassword> --docker-email=<yourEmail>
```

### Persistence

`local`, `cluster`, `azurefiles`, `nfs`, `existingClaim` are possible persistence options.
The default is `local` where `persistence.local.path` need to be set to a valid local folder.

### Add the Intershop Helm repository

Before installing Intershop helm charts, you need to add the [Intershop helm repository](https://intershop.github.io/helm-charts) to your helm client

```bash
helm repo add intershop https://intershop.github.io/helm-charts
helm repo update
```

### Install Chart

To install the chart with the release name `icm-web`

```bash
helm install my-release intershop/icm-web --values=values.yaml --namespace icm-web
```
