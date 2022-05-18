# IOM Helm Chart

Installs/upgrades/deletes [Intershop Order Management](https://www.intershop.com/en/intershop-order-management) deployment on a [Kubernetes](https://kubernetes.io) cluster using the [Helm package manager](https://helm.sh).

## Prerequisites

Production systems for Intershop Order Management (IOM) are usually provided as a service in the Azure Cloud. This service is part of the corresponding Intershop Commerce Platform. Non-production environments require separate agreements with Intershop.

For the purpose of adapting the software to specific customer requirements and/or customer-specific environments, it is also possible to operate IOM (for example for corresponding CI environments, test systems, etc) outside the Azure Cloud and independently of Azure Kubernetes (AKS). In support of this, this document is intended for IOM administrators and software developers.

### IOM Docker Images

IOM is provided in the form of Docker images. These images can be used directly or can be the base for further customization in the context of projects.

The images are available at:

* docker.intershop.de/intershophub/iom-dbaccount:1.4.0
* docker.intershop.de/intershophub/iom:4.0.0

---

Adapt the tag (version number) if you use a newer version of IOM. For a full list of available versions see [Overview - IOM Public Release Notes](TODO).

---

*docker.intershop.de* is a private Docker registry. Private Docker registries require authentication and sufficient rights to pull images from them. The according authentication data can be passed in a Kubernetes secret object, which has to be set using the Helm parameter imagePullSecrets.

The document [Pull an Image from a Private Registry](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/) from Kubernetes documentation explains in general how to create Kubernetes secret objects, suitable to authenticate at a private Docker registry. [Pull images from an Azure container registry to a Kubernetes cluster](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-auth-kubernetes) from Microsoft Azure documentation explains how to apply this concept to private Azure container registries.

The following box shows an example of how to create a Kubernetes secret to be used to access the private Docker registry *docker.intershop.de*. The name of the newly created secret is *intershop-pull-secret*, which has to be passed to Helm parameter *imagePullSecrets*. It has to reside within the same Kubernetes namespace as the IOM cluster which uses the secret.

    #Create Kubernetes secret
    kubectl create secret docker-registry intershop-pull-secret \
        --docker-server=docker.intershop.de \
        --docker-username='[USER NAME]' \
        --docker-password='[PASSWORD]' \
        -n [KUBERNETES NAMESPACE]

## Get Repo Info

    helm repo add intershop https://intershop.github.io/helm-charts
    helm repo update

## Install Chart

    helm install [RELEASE NAME] intershop/iom -f [VALUES FILE] -n [NAMESPACE] --wait --timeout [TIMEOUT]
    
The command deploys IOM on the Kubernetes cluster.

---

To work correctly, the --wait and --timeout command line parameters must always be set when running Helm.

---

*See [configuration](TODO).*

*See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation.*

## Uninstall Chart

    helm uninstall [RELEASE NAME] -n [NAMESPACE]

This removes all the Kubernetes components associated with the chart and deletes the release.

*See [helm uninstall](https://helm.sh/docs/helm/helm_uninstall/) for command documentation.*

## Upgrading Chart

    helm upgrade [RELEASE NAME] intershop/iom -f [VALUES FILE] -n [KUBERNETES NAMESPACE] --wait --timeout [TIMEOUT]

---

To work correctly, the --wait and --timeout command line parameters must always be set when running Helm.

---

*See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation.*

### Restrictions on Rollback

IOM uses a database that is constantly evolving along with new releases of IOM. For this reason, every version of IOM brings its own migration scripts, which are lifting the database to the new level. In general, old versions of the IOM database are not compatible with new versions of IOM application servers and vice versa. Also, projects change the database when rolling out new or changed project configurations.

Helm does not know anything about changes inside the database. When rolling back a release, only the changes in values and IOM Helm-packages are rolled back. To avoid inconsistencies and failures (e.g. rollback to an old IOM application server version after updating the database structures to the new version), it is strongly recommended to avoid rollback in general.

### Restrictions on Upgrade

The same reasons that make the rollback process problematic also limit the upgrade process.

When executing the upgrade process, the standard behavior of Helm is to keep the application always online. The different IOM application servers are updated one after another. In case of incompatible database changes, this would lead to problems, since one of the following cases is unavoidable: an old IOM application server tries to work with an already updated IOM database or vice versa.

To overcome this problem, IOM Helm charts provide the parameter *downtime*, which controls the behavior of the upgrade process. If *downtime* is set to *true*, the whole IOM cluster will be stopped during the upgrade process. The IOM database will be upgraded first and after that, the IOM application servers are started again. This setting should always be used when upgrading to a new IOM version unless stated otherwise.

Within the context of projects, many changes can be applied to the running IOM cluster without requiring a downtime. In this case, the value of *downtime* has to be set to *false* before starting the upgrade process.

---

For security reasons, the default value of *downtime* is *true* to avoid any inconsistencies. Once you have understood the concept of the downtime parameter, you should set it to *false* to avoid downtimes as often as possible, and only set it to *true* when really required.

---

## Configuration

### Parameters

#### IOM

### Database, etc.

## Examples
