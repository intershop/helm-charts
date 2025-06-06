# icm-web



![Version: 0.14.3](https://img.shields.io/badge/Version-0.14.3-informational?style=flat-square) ![AppVersion: 11.0.13](https://img.shields.io/badge/AppVersion-11.0.13-informational?style=flat-square) 

Intershop Commerce Management - Web Adapter and Web Adapter Agent

Installs the ICM web adapter and web adapter agent independently.

## Prerequisites Details

* helm+kubectl
* Kubernetes 1.14+

## Chart Details
This chart will do the following:

* Deploy an ICM Web Adapter and Web Adapter Agent

## Installing the Chart

### Docker pull secret

Create a secret for a docker registry where the images are coming from. The name of the secret must be equal to the configured secrets under `imagePullSecrets` within the application deployment. By default the secret name is `dockerhub`.

```bash
kubectl create secret docker-registry <yourDockerRegistryName> --docker-server=<yourDockerRegistryServer> --docker-username=<yourUsername> --docker-password=<yourPassword> --docker-email=<yourEmail>
```

### Persistence

#### PageCache

`local`, `cluster`, `azurefiles`, `nfs`, `existingClaim` are possible persistence types.
The default is `local` where `persistence.pagecache.local.path` need to be set to a valid local folder.

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

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| agent.deploymentAnnotations | object | `{}` |  |
| agent.deploymentLabels | object | `{}` |  |
| agent.enabled | bool | `true` |  |
| agent.image.pullPolicy | string | `"IfNotPresent"` |  |
| agent.image.repository | string | `"intershophub/icm-webadapteragent:5.1.0"` |  |
| agent.newrelic.apm.enabled | bool | `true` |  |
| agent.newrelic.enabled | bool | `false` |  |
| agent.newrelic.license_key | string | `"secret"` |  |
| agent.newrelic.metrics.enabled | bool | `true` |  |
| agent.podAnnotations | object | `{}` |  |
| agent.podBinding.binding | string | `"<name-of-the-binding>"` |  |
| agent.podBinding.enabled | bool | `false` |  |
| agent.podLabels | object | `{}` |  |
| agent.replicaCount | int | `1` |  |
| agent.updateStrategy | string | `"RollingUpdate"` |  |
| appServerConnection.port | int | `7744` |  |
| appServerConnection.serviceName | string | `"icm-as"` |  |
| environment | object | `{}` |  |
| fullnameOverride | string | `""` |  |
| imagePullSecrets[0] | string | `"dockerhub"` |  |
| ingress.annotations | object | `{}` |  |
| ingress.className | string | `"nginx"` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hosts[0].host | string | `"<dns-name-of-service>"` |  |
| ingress.hosts[0].paths[0].path | string | `"/"` |  |
| ingress.hosts[0].paths[0].pathType | string | `"Prefix"` |  |
| ingress.tls | list | `[]` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| operationalContext.customerId | string | `"n_a"` |  |
| operationalContext.environmentName | string | `"prd"` |  |
| operationalContext.environmentType | string | `"prd"` |  |
| operationalContext.stagingType | string | `"standalone"` |  |
| persistence.customdata.enabled | bool | `false` |  |
| persistence.customdata.existingClaim | string | `"icm-as-cluster-customData-pvc"` |  |
| persistence.customdata.mountPoint | string | `"/data"` |  |
| persistence.logs.azurefiles.secretName | string | `"icm-web-logs-secret"` |  |
| persistence.logs.azurefiles.shareName | string | `"icm-web-logs-share"` |  |
| persistence.logs.cluster.storageClass.create | bool | `true` |  |
| persistence.logs.cluster.storageClass.mountOptions[0] | string | `"uid=150"` |  |
| persistence.logs.cluster.storageClass.mountOptions[1] | string | `"gid=150"` |  |
| persistence.logs.cluster.storageClass.mountOptions[2] | string | `"dir_mode=0777"` |  |
| persistence.logs.cluster.storageClass.mountOptions[3] | string | `"file_mode=0777"` |  |
| persistence.logs.cluster.storageClass.mountOptions[4] | string | `"mfsymlinks"` |  |
| persistence.logs.cluster.storageClass.mountOptions[5] | string | `"cache=strict"` |  |
| persistence.logs.cluster.storageClass.mountOptions[6] | string | `"actimeo=30"` |  |
| persistence.logs.cluster.storageClass.skuName | string | `"Standard_LRS"` |  |
| persistence.logs.existingClaim | string | `"claimName"` |  |
| persistence.logs.local.path | string | `"<local folder>"` |  |
| persistence.logs.nfs.path | string | `"<server folder>"` |  |
| persistence.logs.nfs.server | string | `"<ipaddress or hostname>"` |  |
| persistence.logs.size | string | `"10Gi"` |  |
| persistence.logs.type | string | `"emptyDir"` |  |
| persistence.pagecache.azurefiles.secretName | string | `"icm-web-pc-secret"` |  |
| persistence.pagecache.azurefiles.shareName | string | `"icm-web-pc-share"` |  |
| persistence.pagecache.cluster.storageClass.create | bool | `true` |  |
| persistence.pagecache.cluster.storageClass.mountOptions | list | `["uid=150","gid=150","dir_mode=0777","file_mode=0777","mfsymlinks","cache=strict","actimeo=30"]` | Mount options for the storage class. |
| persistence.pagecache.cluster.storageClass.skuName | string | `"Standard_LRS"` |  |
| persistence.pagecache.existingClaim | string | `"claimName"` |  |
| persistence.pagecache.local.path | string | `"<local folder>"` |  |
| persistence.pagecache.nfs.path | string | `"<server folder>"` |  |
| persistence.pagecache.nfs.server | string | `"<ipaddress or hostname>"` |  |
| persistence.pagecache.size | string | `"1Gi"` |  |
| persistence.pagecache.type | string | `"emptyDir"` | type cluster \| nfs \| azurefiles \| existingClaim \| local \| emptyDir |
| podSecurityContext.fsGroup | int | `150` |  |
| podSecurityContext.fsGroupChangePolicy | string | `"OnRootMismatch"` |  |
| podSecurityContext.runAsGroup | int | `150` |  |
| podSecurityContext.runAsNonRoot | bool | `true` |  |
| podSecurityContext.runAsUser | int | `150` |  |
| resources.agent.limits.cpu | string | `"2000m"` |  |
| resources.agent.limits.memory | string | `"400Mi"` |  |
| resources.agent.requests.cpu | string | `"50m"` |  |
| resources.agent.requests.memory | string | `"100Mi"` |  |
| resources.webadapter.limits.cpu | string | `"100m"` |  |
| resources.webadapter.limits.memory | string | `"400Mi"` |  |
| resources.webadapter.requests.cpu | string | `"100m"` |  |
| resources.webadapter.requests.memory | string | `"400Mi"` |  |
| service.httpPort | int | `8080` |  |
| service.httpsPort | int | `8443` |  |
| service.type | string | `"ClusterIP"` |  |
| webadapter.configMapMounts | list | `[]` |  |
| webadapter.customHttpdConfig | bool | `false` |  |
| webadapter.customSSLCertificates | bool | `false` |  |
| webadapter.deploymentAnnotations | object | `{}` |  |
| webadapter.deploymentLabels | object | `{}` |  |
| webadapter.disableHTTP2 | bool | `false` |  |
| webadapter.image.pullPolicy | string | `"IfNotPresent"` |  |
| webadapter.image.repository | string | `"intershophub/icm-webadapter:2.6.0"` |  |
| webadapter.overrideSSL | bool | `false` |  |
| webadapter.podAnnotations | object | `{}` |  |
| webadapter.podBinding.binding | string | `"<name-of-the-binding>"` |  |
| webadapter.podBinding.enabled | bool | `false` |  |
| webadapter.podLabels | object | `{}` |  |
| webadapter.probes.liveness | object | `{}` |  |
| webadapter.probes.readiness | object | `{}` |  |
| webadapter.probes.startup | object | `{}` |  |
| webadapter.replicaCount | int | `1` |  |
| webadapter.schedulePodsPreferredEvenlyAcrossNodes | bool | `true` |  |
| webadapter.sslCertificateRetrieval.enabled | bool | `false` |  |
| webadapter.sslCertificateRetrieval.keyvault.certificateName | string | `"<name-of-the-certificate>"` |  |
| webadapter.sslCertificateRetrieval.keyvault.keyvaultName | string | `"<name-of-the-KeyVault>"` |  |
| webadapter.sslCertificateRetrieval.keyvault.resourceGroup | string | `"<resource-group-of-the-KeyVault>"` |  |
| webadapter.sslCertificateRetrieval.keyvault.subscriptionId | string | `"<subscription-ID-of-the-KeyVault>"` |  |
| webadapter.sslCertificateRetrieval.keyvault.tenantId | string | `"<tenant-ID-of-the-KeyVault>"` |  |
| webadapter.sslCertificateRetrieval.supportV1 | bool | `false` |  |
| webadapter.updateStrategy | string | `"RollingUpdate"` |  |


----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
