# Helm Chart Intershop Commerce Management - Application Server

Installs the ICM application server independently.

## Prerequisites Details

* helm+kubectl
* Kubernetes 1.14+

## Chart Details

This chart will do the following:

* Deploy an ICM Application Server

## Installing the Chart

### Docker pull secret

Create a secret for a docker registry where the images are coming from. The name of the secret must be equal to the configured secrets under `image.secret` within the application deployment. By default, the secret name is `dockerhub`.

```bash
kubectl create secret docker-registry <yourDockerRegistryName> --docker-server=<yourDockerRegistryServer> --docker-username=<yourUsername> --docker-password=<yourPassword> --docker-email=<yourEmail>
```

### Persistence

#### Sites

`local`, `cluster`, `azurefiles`, `nfs`, `existingClaim` are possible persistence options.
The default is `local` where `persistence.sites.local.path` need to be set to a valid local folder.

#### jGroups

`local`, `cluster`, `azurefiles`, `nfs`, `existingClaim` are possible persistence options.
The default is `emptyDir`.

### Database

The needed database connection could be configured via section `database`. The chart also supports to deploy a (containerized) MSSQL database. If this is enabled the deployed MSSQL database is used instead of the one configured via section `database`.

### Replication/Staging

A replication/staging scenario is supported via the section `replication`. To use this feature just deploy 2 separate icm-as (+ icm-web) one for the source (*edit*) system and one for the target (*live*) system.

### Add the Intershop Helm repository

Before installing Intershop helm charts, you need to add the [Intershop helm repository](https://intershop.github.io/helm-charts) to your helm client.

```bash
helm repo add intershop https://intershop.github.io/helm-charts
helm repo update
```

### Install Chart

To install the chart with the release name `icm-as`

```bash
helm install my-release intershop/icm-as --values=values.yaml --namespace icm-as
```

#### Job Server

If `job.enable==true` the job server functionality of the application server is activated and a child chart [icm-job](../icm-job/README.md) is deployed.
During development you might need to update the dependencies:

```bash
helm dependencies update .
```

### Testing

#### helm-unit

There are helm-unit tests to support development and secure several functionality.

Prerequisites are:

* [helm-unittest](https://github.com/helm-unittest/helm-unittest)

Please check the unit tests before pushing changes.

```bash
helm unittest --helm3 charts/icm-as
```

#### ct lint & install

Prerequisites are:

* [kind cluster](https://github.com/kubernetes-sigs/kind)
* Install cluster: `kind create cluster --config icm-as.yaml`

```bash
docker run -it --network host --workdir=/data --volume <my kube config>:/root/.kube/config:ro --volume
$(pwd):/data quay.io/helmpack/chart-testing:v3.8.0 ct lint --config ct_icm-as.yaml
```