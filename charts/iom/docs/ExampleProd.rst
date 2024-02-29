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

Please keep in mind that these preconditions reflect the use case described in section `IOM Helm-Charts <ToolsAndConcepts.rst#iom-helm-charts>`_.
When using the Intershop Commerce Platform, these preconditions are all covered by Intershop.

- Azure Kubernetes Service (AKS) and virtual machines of sufficient size. 
- Access to a database provided by a PostgreSQL server.
- Access to a File service (e.g. Azure Files)
- Running Ingress controller in AKS
- Secrets for database access, TLS for Ingress, etc.
- Installation of kubectl on the machine that is used for installation, >=v.1.25

  - see: https://kubernetes.io/docs/tasks/tools/
- Installation of Helm on the machine that is used for installation, >= v.3.8

  - see: https://helm.sh/docs/intro/install/
- Access to AKS from the machine used for installation
- Access to `IOM Docker images <ToolsAndConcepts.rst#iom-docker-images>`_
- Access to `IOM Helm-charts`_

Requirements and Characteristics of IOM Installation
====================================================

Requirements and characteristics are numbered again. You will find these numbers in the `values file`_ listed below in order to see the relation between requirement and current configuration.

1. Two IOM application servers must run in parallel.
2. Usage of an external PostgreSQL service.
3. No reset of database during the installation process. 
4. Usage of an external SMTP server.
5. Shared file system of IOM located on externally provided resources.
6. Usage of an external NGINX Ingress controller.
7. The system should be able to be upgraded without downtime.
8. Time for initialization, migration, and configuration has to be adapted due to the specific characteristics of the project.

Values File
===========

The values file shown below reflects the requirements of the straight Helm approach as described in section `IOM Helm-Charts`_ to demonstrate
this process in all its details. Within the `Intershop Commerce Platform <ToolsAndConcepts.rst#intershop-commerce-platform>`_ environment,
you would edit the values file only. Any further actions are triggered automatically when pushing changes made in the file.

Of course, this values file cannot be copied as it is. It references external resources and external services which do not exist in other
environments. Additionally, the hostname iom.mycompany.com needs to be replaced to match your requirements.

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

  # specify the time that is available for initialization, migration, and
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

  # IOM has to know its own public URL
  oms:
    publicUrl: "https://iom.mycompany.com/"
    db:
      # database has to already exist.
      name: oms_db
      user: oms_user
      passwdSecretKeyRef:
        name: mycompany-prod-secrets
        key: dbpasswd
      # do not reset database (requirement #3)
      resetData: false # optional, default value is false
    # configuration of external smtp server (requirement #4)
    smtp:
      host: smpt.external-provider.com
      port: 25
      user: my-company-prod
      passwdSecretKeyRef:
        name: mycompany-prod-secrets
        key: smtppasswd

  project:
    envName: prod

  # store data of shared file system at azurefile service (requirement #5)
  persistence:
    storageSize: 60G
    dynamic:
      storageClass: azurefile-iom
      annotations:

Installation of IOM
===================

Create a file *values.yaml* and fill it with the content listed above in `Values File`_. Adapt all the changes to the file that are required
by your environment. After that, the installation process can be started.

.. code-block:: shell

  # create namespace mycompany-iom
  kubectl create namespace mycompany-iom
 
  # install IOM into namespace mycompany-iom
  helm install ci intershop/iom --values=values.yaml --namespace mycompany-iom --timeout 30m0s --wait		

This installation process will now take some minutes to finish. In the meantime, the progress of the installation process can be observed within
a second terminal window. Using *kubectl*, you can see the status of every Kubernetes object. For simplicity, the following example shows the
status of pods only.

Just open a second terminal window and enter the following commands.

.. code-block::

  # One second after start, all pods are in very early phases.
  kubectl get pods -n mycompany-iom
  NAME                                                 READY   STATUS              RESTARTS   AGE
  prod-iom-0                                           0/1     Pending             0          1s

  # After a few seconds IOM is "Running", but not "READY" yet. The database will now be filled,
  # migrated and configured. IOM- and project-applications are then deployed into the Wildfly
  # application server.
  kubectl get pods -n mycompany-iom
  NAME                                                 READY   STATUS    RESTARTS   AGE
  prod-iom-0                                           0/1     Running   0          43s

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

When all pods are *Running* and *Ready*, the installation process has finished. You should check the first terminal window where the
installation process was started.

Upgrade of IOM
==============

Now we repeat the upgrade process, which was already shown in the `previous example <ExampleDemo.rst>`_. This simple example was chosen
because from a *Helm* perspective, the rollout of any change in values or charts is an upgrade process. The process is identical, no
matter if only a simple value is changed or if new Docker images of a new IOM release are rolled out.

Also, setting the *downtime* parameter (see: `Restrictions on Upgrade <ToolsAndConcepts.rst#restrictions-on-upgrade>`_) is considered.
A change of a log-level is an uncritical change which can be applied without downtime. Since we have more than one IOM application
server, the upgrade process can now be executed without downtime.

Add the following lines to the *values.yaml*:

.. code-block:: yaml

  log:
    level:
      quartz: INFO

These changes are now rolled out by running the *Helm* upgrade process to the existing IOM installation. Start the process within a terminal window.

.. code-block: shell

  helm upgrade ci intershop/iom --values=values.yaml --namespace mycompany-iom --timeout 30m0s --wait

The upgrade process will take some minutes before being finished.

In the `previous example <ExampleDemo.rst>`_ you may have noticed that the behavior of pods during the installation process is identical no matter which Kubernetes environment was used (Docker Desktop, AKS). The same applies to the upgrade process. For this reason, the box "Observe progress" will be skipped in the current section.

Uninstall IOM
=============

The last process demonstrates how to uninstall IOM. Please keep in mind that the uninstall process only covers the objects defined in IOM Helm-charts. In the current production example many external resources and external services are referenced. These resources and services remain untouched by the uninstall process of IOM.

.. code-block:: shell

  # uninstall IOM release
  helm uninstall prod -n mycompany-iom
  release "prod" uninstalled

  # Create a backup of the content located in dynamically created *persistent-volume*.
  # After that, the according *persistent-volume* has to be deleted manually.
  # The steps to do so are not shown here.
  
  # delete Kubernetes namespace used for IOM
  kubectl delete namespace mycompany-iom
  namespace "mycompany-iom" deleted

+---------------------+-----------------+-------------------------+
|`< Back              |`^ Up            |`Next >                  |
|<ExampleDemo.rst>`_  |<../README.rst>`_|<ParametersIOM.rst>`_    |
+---------------------+-----------------+-------------------------+
