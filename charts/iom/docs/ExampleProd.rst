+---------------------+-----------------+-------------------------+
|`< Back              |`^ Up            |`Next >                  |
|<ExampleDemo.rst>`_  |<../README.rst>`_|<ParametersIOM.rst>`_    |
+---------------------+-----------------+-------------------------+

================================================
Helm Charts for Intershop Order Management (IOM)
================================================

----------------------------------------
Production System Running in Azure Cloud
----------------------------------------

Preconditions
=============

Please keep in mind that these preconditions reflect the use case described in section `IOM Helm-Charts <ToolsAndConcepts.rst#iom-helm-charts>`_. When using the Intershop Commerce Platform, these preconditions are all covered by Intershop.

* Azure Kubernetes Service (AKS) and virtual machines of sufficient size. 
* Access to a PostgreSQL server preferred as "Azure Database for PostgreSQL servers".
* Access to a File service (e.g. Azure Files)
* Running Ingress controller in AKS
* Secrets for database access, TLS for Ingress, etc.
* Installation of kubectl on the machine that is used for installation, >=v.1.22

  * see: https://kubernetes.io/docs/tasks/tools/
* Installation of Helm on the machine that is used for installation, >= v.3.6

  * see: https://helm.sh/docs/intro/install/
* Access to AKS from the machine used for installation
* Access to `IOM Docker images <ToolsAndConcepts.rst#iom-docker-images>`_
* Access to `IOM Helm-charts`_

Requirements and Characteristics of IOM Installation
====================================================

Requirements and characteristics are numbered again. You will find these numbers in the `values file`_ listed below in order to see the relation between requirement and current configuration.

* Two IOM application servers must run in parallel.
* Usage of an external PostgreSQL server (Azure Database for PostgreSQL server).
* No reset of PostgreSQL data during the installation process. 
* Usage of an external SMTP server.
* Shared file system of IOM located on externally provided resources.
* Usage of an external NGINX Ingress controller.
* The system should be able to be upgraded without downtime.
* Time for initialization, migration, and configuration has to be increased due to the specific characteristics of the project.

Values File
===========

The values file shown below reflects the requirements of the straight Helm approach as described in section `IOM Helm-Charts`_ to demonstrate this process in all its details. Within the `Intershop Commerce Platform <ToolsAndConcepts.rst#intershop-commerce-platform>`_ environment you would edit the values file only. Any further actions are triggered automatically when pushing changes made in the file.

Of course, this values file cannot be copied as it is. It references external resources and external services, which do not exist in other environments. Additionally, the hostname iom.mycompany.com needs to be replaced to match your requirements.

.. code-block:: yaml

  # start 2 IOM application servers (requirement #1)
  replicaCount: 2

  # run upgrade processes without downtime (requirement #7)
  downtime: false

  imagePullSecrets:
    - name: project-pull-secret

  # an image containing the project-specific customizations and 
  # configurations will be used.
  image:
    repository: "project-repository/iom-project"
    tag: "1.0.0"

  # increase the time that is available for initialization, migration, and
  # configuration (requirement #8)
  startupProbe:
    failureThreshold: 120

  # configure Ingress to forward requests to IOM, which are sent to 
  # host iom.mycompany.com. Integrated NGINX Ingress controller is
  # disabled per default (requirement #6).
  ingress:
    enabled: true
    hosts:
      - host: iom.mycompany.com
        paths: 
          - path: /
            pathType: Prefix
    tls:
      - secretName: mycompany-com-tls
        hosts:
          - iom.mycompany.com

  # information about external postgresql service (requirement #2)
  pg:
    host: postgres-prod.postgres.database.azure.com
    port: 5432
    userConnectionSuffix: "@postgres-prod"

    # root-database and superuser information. The very first installation initializes
    # the database of IOM. After that, these information should be removed from values
    # file completely (and dbaccount should be disabled/removed too)
    user: postgres
    passwdSecretKeyRef:
      name: mycompany-prod-secrets
      key: pgpasswd
    db: postgres

  # IOM has to know its own public URL
  oms:
    publicUrl: "https://iom.mycompany.com/"
    db:
      name: oms_db
      user: oms_user
      passwdSecretKeyRef:
        name: mycompany-prod-secrets
        key: dbpasswd
    # configuration of external smtp server (requirement #4)
    smtp:
      host: smpt.external-provider.com
      port: 25
      user: my-company-prod
      passwdSecretKeyRef:
        name: mycompany-prod-secrets
        key: smtppasswd

  log:
    metadata:
      tenant: mycompany
      environment: prod

  project:
    envName: prod

  # store data of shared file system at azurefile service (requirement #5)
  persistence:
    storageClass: azurefile
    storageSize: 60G

  # Create IOM database and according user before starting IOM. Creates IOM database
  # while running install process. After that, dbaccount should be completely removed
  # from the values file. Without set explicitly, data are not reset during start
  # (requirement #3).
  dbaccount:
    enabled: true
    image:
      repository: docker.intershop.de/intershophub/iom-dbaccount
      tag: "1.4.0"

Installation of IOM
===================

Create a file *values.yaml* and fill it with the content listed above in `Values File`_. Adapt all the changes to the file that are required by your environment. After that, the installation process can be started.

.. code-block:: shell

  # create namespace mycompany-iom
  kubectl create namespace mycompany-iom
 
  # install IOM into namespace mycompany-iom
  helm install ci intershop/iom --values=values.yaml --namespace mycompany-iom --timeout 20m0s --wait		

This installation process will now take some minutes to finish. In the meantime, the progress of the installation process can be observed within a second terminal window. Using *kubectl*, you can see the status of every Kubernetes object. For simplicity, the following example shows the status of pods only.

Just open a second terminal window and enter the following commands.

.. code-block::

  # One second after start, all pods are in very early phases.
  kubectl get pods -n mycompany-iom
  NAME                                                 READY   STATUS              RESTARTS   AGE
  prod-iom-0                                           0/1     Pending             0          1s

  # Little bit later, IOM is in initialization phase, which means the init-container is currently executed.
  kubectl get pods -n mycompany-iom
  NAME                                                 READY   STATUS     RESTARTS   AGE
  prod-iom-0                                           0/1     Init:0/1   0          24s

  # After a few minutes IOM is "Running", but not "READY" yet. The init-container is finished
  # now and the database is initialized, migrated, configured, IOM- and project-applications are 
  # deployed into the Wildfly application server.
  kubectl get pods -n mycompany-iom
  NAME                                                 READY   STATUS    RESTARTS   AGE
  prod-iom-0                                           0/1     Running   0          2m43s

  # The first iom-pod is "Running" and "READY", which means the IOM System is usable now.
  # The second iom-pod has just started and is not ready yet.
  kubectl get pods -n mycompany-iom
  NAME                                                 READY   STATUS     RESTARTS   AGE
  prod-iom-0                                           1/1     Running    0          5m35s
  prod-iom-1                                           0/1     Running    0          10s

  # Both iom-pods are "Running" and "READY". Installation of IOM is finished.
  kubectl get pods -n mycompany-iom
  NAME                                                 READY   STATUS    RESTARTS   AGE
  prod-iom-0                                           1/1     Running   0          10m
  prod-iom-1                                           1/1     Running   0          5m49s

When all pods are *Running* and *Ready*, the installation process has finished. You should check the first terminal window where the installation process was started.

Upgrade of IOM
==============

Now we repeat the upgrade process, which was already shown in the `previous example <ExampleDemo.rst>`_. This simple example was chosen because from a *Helm* perspective, the rollout of any change in values or charts is an upgrade process. The process is identical, no matter if only a simple value is changed or if new Docker images of a new IOM release are rolled out.

Also setting the *downtime* parameter (see: `Restrictions on Upgrade <ToolsAndConcepts.rst#restrictions-on-upgrade>`_) is considered. A change of a log-level is an uncritical change which can be applied without downtime. Since we have more than one IOM application server, the upgrade process can now be executed without downtime.

Add the following lines to the *values.yaml*:

.. code-block:: yaml

  log:
    level:
      quartz: INFO

These changes are now rolled out by running the *Helm* upgrade process to the existing IOM installation. Start the process within a terminal window.

.. code-block: shell

  helm upgrade ci intershop/iom --values=values.yaml --namespace mycompany-iom --timeout 20m0s --wait

The upgrade process will take some minutes before being finished.

In the `previous example <ExampleDemo.rst>`_ you may have noticed that the behavior of pods during the installation process is identical no matter which Kubernetes environment was used (Docker Desktop, AKS). The same applies to the upgrade process. For this reason, the box "Observe progress" will be skipped in the current section.

Uninstall IOM
=============

The last process demonstrates how to uninstall IOM. Please keep in mind that the uninstall process only covers the objects defined in IOM Helm-charts. In the current production example many external resources and external services are referenced. These resources and services remain untouched by the uninstall process of IOM.

.. code-block:: shell

  # uninstall IOM release
  helm uninstall prod -n mycompany-iom
  release "prod" uninstalled
  
  # delete Kubernetes namespace used for IOM
  kubectl delete namespace mycompany-iom
  namespace "mycompany-iom" deleted

+---------------------+-----------------+-------------------------+
|`< Back              |`^ Up            |`Next >                  |
|<ExampleDemo.rst>`_  |<../README.rst>`_|<ParametersIOM.rst>`_    |
+---------------------+-----------------+-------------------------+
