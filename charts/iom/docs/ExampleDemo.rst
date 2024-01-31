+------------------------+-----------------+-------------------------+
|`< Back                 |`^ Up            |`Next >                  |
|<ToolsAndConcepts.rst>`_|<../README.rst>`_|<ExampleProd.rst>`_      |
+------------------------+-----------------+-------------------------+

================================================
Helm Charts for Intershop Order Management (IOM)
================================================

-------------------------------------------------------
Local Demo System Running in Docker Desktop on Mac OS X
-------------------------------------------------------

Preconditions
=============

- Mac computer: Mac OS X >= v.14.1
- Sufficient hardware resources: >= 16 GB main memory, multicore CPU
- Installation of Docker Desktop: >= v.4.25.2

  - See: https://www.docker.com/products/docker-desktop 
  - >= 12 GB memory and >= 2 CPUs have to be assigned (Settings | Resources | Advanced)
  - Enable Kubernetes (Preferences | Kubernetes)
  - Directories used to hold persistent data have to be shared with Docker Desktop (Settings | Resources | File Sharing)
- Installation of Helm: >= v3.6

  - See: https://helm.sh/docs/intro/install/
- Access to `IOM Docker images <ToolsAndConcepts.rst#iom-docker-images>`_
- Access to `IOM Helm-charts <ToolsAndConcepts.rst#iom-helm-charts>`_

Requirements and Characteristics of IOM Installation
====================================================

Requirements and characteristics are numbered. You can also find these numbers in the `values file`_ listed below to see the relation between requirements and current configuration.

1. Usage of integrated *PostgreSQL* database server.
2. *PostgreSQL* data are stored persistently.
3. No reset of database during the installation process.
4. Usage of the integrated SMTP server (*Mailpit*).
5. Web access to the GUI of *Mailpit*.
6. The shared file system of IOM has to be stored persistently.
7. Local access to the shared file system of IOM.
8. Due to limited resources, only one IOM application server should run.
9. No access from another computer required.

Values File
===========

This values file cannot be copied as it is. Before it can be used, *persistence.local.hostPath* and *postgres.persistence.local.hostPath* have to be changed to existing paths,
which are shared with Docker Desktop.

The values file contains minimal settings only, except for *oms.db.resetData*, which is explicitly listed, even if it contains only the default value.

.. code-block:: yaml

  # use one IOM server only (requirement #8).
  replicaCount: 1

  imagePullSecrets:
    - name: intershop-pull-secret

  image:
    repository: "docker.tools.intershop.com/iom/intershophub/iom"
    tag: "5.0.0"

  # Define a timeout for startupProbe, that matches the requirements of the current
  # IOM installation. In combination with the default values, this configuration results
  # in a timeout value of 11 minutes for the initialization and migration of the database.
  startupProbe:
    failureThreshold: 60
    
  # Remove resource binding for CPU. This makes the system significantly
  # faster, especially the startup.
  resources:
    limits:
      cpu:
    requests:
      cpu:
  
  # Configure ingress to forward requests for host "localhost" to IOM (requirement #9).
  ingress:
    enabled: true
    hosts:
      - host: localhost
        paths: 
          - path: "/"
            pathType: Prefix

  # IOM has to know its own public URL.
  oms:
    publicUrl: "https://localhost/"
    db:
      # Do not reset existing data during installation (requirement #3).
      resetData: false # Optional, since false is default.

  # Store data of shared-FS into a local directory (requirement #6, #7).
  persistence:
    provisioning: local
    local:
      hostPath: /Users/username/iom-share

  # Create IOM database and according database users before starting IOM. 

  dbaccount:
    enabled: true
    image:
      repository: "docker.tools.intershop.com/iom/intershophub/iom-dbaccount"
      tag: "2.0.0"

  # Use integrated PostgreSQL server (requirement #1).
  # Store database data persistently into a local directory (requirement #2).
  postgres:
    enabled: true
    persistence:
      enabled: true
      provisioning: local
      local:
        hostPath: /Users/username/pgdata

  # Enable integrated SMTP server (requirement #4).
  # Configure Ingress to forward requests for any host to Mailpit GUI (requirements #5).
  # Since ingress for IOM defined a more specific rule, Mailpit GUI can be reached using any hostname except localhost.
  mailpit:
    enabled: true
    ingress:
      hostname:
      # TODO test if this is working!
      
.. regualar notes are not rendered correctly in GitHub
              
**Note**
   
  **Windows: IOM Share and PostgreSQL data**
   
  The current example needs some modifications when running in Docker Desktop on Windows. When working on Windows in combination with *WSL 2* (Windows Subsystem for Linux 2), 
  you must must be careful to use Unix-style pathnames. For example, if the IOM share is located at ``C:\Users\username\iom-share``, the according entry in *values.yaml* has to
  be noted as ``/c/Users/unsername/iom-share``. Additionally the prefix ``/run/desktop/mnt/host`` has to be used.

  The modified configuration of the shared file system has to look like that:

  .. code-block:: yaml
                  
    persistence:
      provisioning: local
      local:
        hostPath: /run/desktop/mnt/host/c/Users/username/iom-share

  The same modifications have to be applied to the configuration of persistent storage of the postgres sub-chart.

  Please also consult documentation about `Persistent Storage <PersistentStorage.rst>`_.

Installation of NGINX Ingress Controller
========================================

The installation of an *Ingress Controller* is a precondition for the installation of IOM. The *Ingress Controller* must support session stickiness, which is required by IOM. If the *NGINX Ingress Controller* is used, this precondition is satisfied and additionally the IOM Helm Charts are configuring the *NGINX Ingress Controller* right out of the box to enable session stickiness.

The easiest way to install the *NGINX Ingress Controller* is by using the according Helm Charts. With the help of *Helm* the *NGINX Ingress Controller* will be installed within a separate Kubernetes namespace.

.. code-block:: shell

  # get ingress-nginx Helm Charts
  helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
  helm repo update
		
  # create namespace "nginx"
  kubectl create namespace nginx

  # install NGINX Ingress controller into namespace "nginx"
  helm install global ingress-nginx/ingress-nginx -n nginx --timeout 10m0s --wait
  
Installation of IOM
===================

Create a file *values.yaml* and fill it with the content shown in section `values file`_. Adapt the settings of *persistence.local.hostPath* and *postgres.persistence.local.hostPath* to point to directories on your computer, which are shared with Docker Desktop. After that, the installation process of IOM can be started.

.. code-block:: shell

  # create diretories for persistent storage
  mkdir -p ~/iom-share ~/pgdata
		
  # create namespace "iom"
  kubectl create namespace iom

  # install IOM into namespace "iom"
  helm install demo intershop/iom --values=values.yaml --namespace iom --timeout 20m0s --wait		

This installation process will now take some minutes to finish. In the meantime, the progress of the installation process can be observed within a second terminal window. You can use *kubectl* to see the status of any Kubernetes object. For simplicity, the following example shows the status of pods only.

Open a second terminal window and enter the following commands:

.. code-block::

  # A few seconds after start of IOM, only the integrated Postgres server is in "Init" phase. All other
  # pods are in earlier phases.
  kubectl get pods -n iom
  NAME                                                  READY   STATUS              RESTARTS   AGE
  demo-iom-0                                            0/1     Pending             0          2s
  demo-mailpit-5dd4565b98-jphkm                         0/1     ContainerCreating   0          2s
  demo-postgres-7b796887fb-j4hdr                        0/1     Init:0/1            0          2s

  # After some seconds all pods except IOM are "Running" and READY (integrated PostgreSQL server, integrated 
  # SMTP server). IOM is in Init-phase, which means the init-container is currently executed.
  kubectl get pods -n iom
  NAME                                                  READY   STATUS     RESTARTS   AGE
  demo-iom-0                                            0/1     Init:1/2   0          38s
  demo-mailpit-5dd4565b98-jphkm                         1/1     Running    0          38s
  demo-postgres-7b796887fb-j4hdr                        1/1     Running    0          38s

  # The init-container executed in iom-pod is dbaccount. Log messages can be seen
  # by executing the following command. If everything works well, the last message will announce the
  # successful execution of the create_dbaccount.sh script.
  kubectl logs demo-iom-0 -n iom -f -c dbaccount
  ...
  {"logHost":"demo-iom-0","logVersion":"1.0","appName":"iom-dbaccount","appVersion":"2.0.0","logType":"script","timestamp":"2023-11-06T11:33:17+00:00","level":"INFO","processName":"create_dbaccount.sh","message":"success","configName":null}

  # When the init-container has been successfully executed, the iom-pod is now also in the "Running" state. However, it is not "READY"
  # yet. Now the IOM database is set up, applications and project customizations are deployed into the Wildfly application server.
  kubectl get pods -n iom
  NAME                                                  READY   STATUS    RESTARTS   AGE
  demo-iom-0                                            0/1     Running   0          1m50s
  demo-mailpit-5dd4565b98-jphkm                         1/1     Running   0          1m50s
  demo-postgres-7b796887fb-j4hdr                        1/1     Running   0          1m50s

  # Once all pods are "Running" and "READY", the installation process of IOM is finished.
  kubectl get pods -n iom
  NAME                                                  READY   STATUS    RESTARTS   AGE
  demo-iom-0                                            1/1     Running   0          3m20s
  demo-mailpit-5dd4565b98-jphkm                         1/1     Running   0          3m20s
  demo-postgres-7b796887fb-j4hdr                        1/1     Running   0          3m20s

When all pods are *Running* and *Ready*, the installation process is finished. You should check the first terminal window, where the installation process was running.

Now the web GUI of the new IOM installation can be accessed. In fact, there are two Web GUIs, one for IOM and one for Mailpit. According to the configuration, all requests dedicated to *localhost* will be forwarded to the IOM application server, any other requests are meant for an integrated SMTP server (*Mailpit*). Open the URL https://localhost/omt in a web browser on your Mac. After accepting the self-signed certificate (the configuration did not include a valid certificate), you will see the login page of IOM. Login as *admin/!InterShop00!* to proceed.

Any other request that is not dedicated to localhost will be forwarded to *Mailpit*. To access the web-GUI of *Mailpit*, open the URL https://127.0.0.1/ in your web browser. Once again you have to accept the self-signed certificate and after that, you will see the *Mailpit* GUI.

Upgrade IOM
===========

From a Helm perspective, the rollout of any change in values or charts is an upgrade process. The process is the same regardless of whether you are changing a simple value or deploying new Docker images of a new IOM version. The example shown here demonstrates how to change the log level of the *Quartz* subsystem running in the WildFly application server.

Before you begin, keep the `restrictions on upgrade <ToolsAndConcepts.rst#restrictions-on-upgrade>`_ in mind. Changing a log level is an uncritical change that can be applied without downtime. However, we have decided to use a single IOM application server only (see Requirement #8). When using a single IOM application server only, an upgrade process with downtime is inevitable. Therefore, we do not need to consider setting the *downtime* parameter.

1. Modify ``values.yaml`` by adding the following lines to the file:

   .. code-block:: yaml

     log:
       level:
         quartz: INFO		  
		   
   These changes are now rolled out by running Helm's upgrade process to the existing IOM installation.

2. Start the upgrade process within a terminal window.

   .. code-block:: shell

     helm upgrade demo intershop/iom --values=values.yaml --namespace iom --timeout 20m0s --wait

   The upgrade process will take some minutes before it is finished.

3. Enter the following commands in a second terminal window to watch the progress.
   As already used in the installation process before, this example is restricted to the status of pods only.

   .. code-block::

     # Only the Kubernetes object of IOM has changed. Therefore Helm only upgrades IOM, the integrated SMTP server
     # and the integrated PostgreSQL server are running unchanged. A few seconds after starting the
     # upgrade process, the only existing iom-pod is stopped.
     kubectl get pods -n iom
     NAME                                                  READY   STATUS        RESTARTS   AGE
     demo-iom-0                                            1/1     Terminating   0          40m
     demo-mailpit-5dd4565b98-jphkm                         1/1     Running       0          40m
     demo-postgres-7b796887fb-j4hdr                        1/1     Running       0          40m

     # After the iom-pod is terminated, a new iom-pod is started with new configuration.
     kubectl get pods -n iom
     NAME                                                  READY   STATUS     RESTARTS   AGE
     demo-iom-0                                            0/1     Running    0          56s
     demo-mailpit-5dd4565b98-jphkm                         1/1     Running    0          41m
     demo-postgres-7b796887fb-j4hdr                        1/1     Running    0          41m

     # Finally the pod is "Running" and "READY" again, which means, IOM is up again.
     kubectl get pods -n iom
     NAME                                                  READY   STATUS    RESTARTS   AGE
     demo-iom-0                                            1/1     Running   0          2m40s
     demo-mailpit-5dd4565b98-jphkm                         1/1     Running   0          46m
     demo-postgres-7b796887fb-j4hdr                        1/1     Running   0          46m

Uninstall NGINX Ingress Controller and IOM
==========================================

The last process demonstrates how to uninstall IOM and NGINX Ingress controller:

.. code-block::

  helm uninstall demo -n iom
  release "demo" uninstalled

  kubectl delete namespace iom
  namespace "iom" deleted

  helm uninstall global -n nginx
  release "global" uninstalled

  kubectl delete namespace nginx
  namespace "nginx" deleted
  

Since database data and shared file system of IOM were stored in local directories on the current host, they still exist after uninstalling IOM. In fact, this data represents the complete state of IOM. If we were to reinstall IOM with the same directories for shared file system and database data, the old IOM installation would be reincarnated.

+------------------------+-----------------+-------------------------+
|`< Back                 |`^ Up            |`Next >                  |
|<ToolsAndConcepts.rst>`_|<../README.rst>`_|<ExampleProd.rst>`_      |
+------------------------+-----------------+-------------------------+
