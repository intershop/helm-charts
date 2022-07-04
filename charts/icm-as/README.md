# Helm Chart Intershop Commerce Management - Application Server

Installs the ICM application server independently.

## Prerequisites Details

* helm+kubectl
* Kubernetes 1.14+
* Valid license file

## Chart Details
This chart will do the following:

* Deploy an ICM Application Server

## Installing the Chart

### Docker pull secret
Create a secret for a docker registry where the images are coming from. The name of the secret must be equal to the configured secrets under `image.secret` within the application deployment. By default the secret name is `dockerhub`.

```bash
$ kubectl create secret docker-registry <yourDockerRegistryName> --docker-server=<yourDockerRegistryServer> --docker-username=<yourUsername> --docker-password=<yourPassword> --docker-email=<yourEmail>
```

### License file

A license file could either be provided with `helm install ... --set-file license.configMap.content=./license.xml` via ConfigMap or using an [Azure Key Vault Provider for Secrets Store CSI Driver](https://docs.microsoft.com/de-de/azure/aks/csi-secrets-store-driver). Both types are configured in the `values.yaml`.

### Persistence

`local`, `cluster`, `azurefiles`, `nfs`, `existingClaim` are possible persistence options.
The default is `local` where `persistence.local.path` need to be set to a valid local folder.

### Database

The needed database connection could be configured via environment variables in the [values.yaml](values.yaml) (see `INTERSHOP_JDBC_*`).

### Add the Intershop Helm repository

Before installing Intershop helm charts, you need to add the [Intershop helm repository](https://intershop.github.io/helm-charts) to your helm client

```bash
$ helm repo add intershop https://intershop.github.io/helm-charts
$ helm repo update
```

### Install Chart
To install the chart with the release name `icm-as`
```bash
$ helm install my-release intershop/icm-as --values=values.yaml --namespace icm-as
```
