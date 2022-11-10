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

* Mac computer: Mac OS X >= v.12.1
* Sufficient hardware resources: >= 16 GB main memory, multicore CPU
* Installation of Docker Desktop: >= v.4.3

  * See: https://www.docker.com/products/docker-desktop 
  * >= 12 GB memory and >= 2 CPUs have to be assigned (Preferences | Resources | Advanced)
  * Enable Kubernetes (Preferences | Kubernetes)
  * Directories used to hold persistent data have to be shared with Docker Desktop (Preferences | Resources | File Sharing)
* Installation of Helm: >= v3.6

  * See: https://helm.sh/docs/intro/install/
* Access to `IOM Docker images <ToolsAndConcepts.rst#iom-docker-images>`_
* Access to `IOM Helm-charts <ToolsAndConcepts.rst#iom-helm-charts>`_

Requirements and Characteristics of IOM Installation
====================================================

Requirements and characteristics are numbered. You will find these numbers also in the `values file`_ listed below in order to see the relation between requirement and current configuration.
Usage of integrated PostgreSQL server.

1. Usage of integrated *PostgreSQL* database server.
2. *PostgreSQL* data are stored persistently.
3. No reset of *PostgreSQL* data during the installation process.
4. Usage of the integrated SMTP server (*Mailhog*).
5. Web access to the GUI of *Mailhog*.
6. The shared file system of IOM has to be stored persistently.
7. Local access to the shared file system of IOM.
8. Due to limited resources, only one IOM application server should run.
9. No access from another computer required.

Values File
===========

This values file cannot be copied as it is. Before it can be used, *persistence.hostPath* and *postgres.persistence.hostPath* have to be changed to existing paths, which are shared with Docker Desktop.

The values file contains minimal settings only, except *dbaccount.resetData*, which was listed explicitly, even if it contains the default value only.

.. code-block:: yaml

  # use one IOM server only (requirement #8).
  replicaCount: 1

  imagePullSecrets:
    - name: intershop-pull-secret

  image:
    repository: "docker.tools.intershop.com/iom/intershophub/iom"
    tag: "4.3.0"

  # define a timeout for startupProbe, that is matching the requirements of the current
  # IOM installation. In combination with the default values, this configuration results
  # in a timeout value of 11 minutes for the initialization and migration of the database.
  startupProbe:
    failureThreshold: 60
    
  # remove resource binding for cpu. This makes the system significantly
  # faster, especially the startup.
  resources:
    limits:
      cpu:
    requests:
      cpu:
  
  # configure ingress to forward requests for host "localhost" to IOM (requirement #9).
  ingress:
    enabled: true
    hosts:
      - host: localhost
        paths: 
          - path: "/"
            pathType: Prefix

  # IOM has to know its own public URL
  oms:
    publicUrl: "https://localhost/"

  # store data of shared-FS into local directory (requirement #6, #7)
  persistence:
    hostPath: /Users/username/iom-share

  # create IOM database and according database user before starting IOM. 
  # do not reset existing data during installation (requirement #3)
  dbaccount:
    enabled: true
    resetData: false # optional, since false is default
    image:
      repository: "docker.tools.intershop.com/iom/intershophub/iom-dbaccount"
      tag: "1.6.0"

  # use integrated PostgreSQL server (requirement #1).
  # store database data persistently into local directory (requirement #2).
  postgres:
    enabled: true
    persistence:
      enabled: true
      hostPath: /Users/username/pgdata

  # enable integrated SMTP server (requirement #4).
  # configure ingress to forward requests for any host to mailhog GUI (requirements #5).
  # since ingress for IOM defined a more specific rule, mailhog GUI can be reached using any hostname except localhost.
  mailhog:
    enabled: true
    ingress:
      enabled: true
      hosts:
        - host:
          paths:
            - path: "/"
              pathType: Prefix

.. note:: 

  **Windows: IOM Share**
   
  The current example just works when using Docker Desktop on Windows. When working on Windows, you have to take care to use Unix-Style path names, e.g., if the IOM share is located at C:\Users\username\iom-share, the according entry in values.yaml has to be noted as /c/Users/unsername/iom-share.

.. note::

  **Windows: persistent PostgreSQL data**
   
  Setting *postgresql.persistence.hostPath* to a local directory does not work on Windows, even if the directory is correctly shared with Docker Desktop. When starting the PostgreSQL server, it tries to take ownership of the data directory, which is not working in this case. There are two possibilities to overcome this problem:
  
  * Do not store PostgreSQL data persistently, by setting *postgres.persistence.enabled* to false.
  * Use a Docker volume for persistent storage of PostgreSQL data. The following box shows how to do this.

.. code-block:: shell

  # create docker volume "iom-pgdata"
  docker volume create —name=iom-pgdata -d local

  # get mount-point of newly created docker volume
  # use mount-point as value for helm-parameter postgres.persistence.hostPath
  docker volume inspect —format='{{.Mountpoint}}' iom-pgdata
  /var/lib/docker/volumes/iom-pgdata/_data

  # to remove docker volume, execute the following command
  docker volume rm iom-pgdata

Installation of NGINX Ingress Controller
========================================

The installation of an *Ingress Controller* is a precondition for the installation of IOM. The *Ingress Controller* has to have support session stickiness, which is required by IOM. If the *NGINX Ingress Controller* is used, this precondition is satisfied and additionally the IOM Helm Charts are configuring the *NGINX Ingress Controller* right oit of the box to enable session stickiness.

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

Create a file *values.yaml* and fill it with the content shown in section `values file`_. Adapt the settings of *persistence.hostPath* and *postgres.persistence.hostPath* to point to directories on your computer, which are shared with Docker Desktop. After that, the installation process of IOM can be started.

.. code-block:: shell

  # create diretories for persistent storage
  mkdir -p ~/iom-share ~/pgdata
		
  # create namespace "iom"
  kubectl create namespace iom

  # install IOM into namespace "iom"
  helm install demo intershop/iom --values=values.yaml --namespace iom --timeout 20m0s --wait		

This installation process will now take some minutes to finish. In the meantime, the progress of the installation process can be observed within a second terminal window. Using *kubectl* you can see the status of every Kubernetes object. For simplicity, the following example is showing the status of pods only.

Open a second terminal window and enter the following commands.

.. code-block::

  # A few seconds after start of IOM, only the integrated Postgres server is in "Init" phase. All other
  # pods are in earlier phases.
  kubectl get pods -n iom
  NAME                                                  READY   STATUS              RESTARTS   AGE
  demo-iom-0                                            0/1     Pending             0          2s
  demo-mailhog-5dd4565b98-jphkm                         0/1     ContainerCreating   0          2s
  demo-postgres-7b796887fb-j4hdr                        0/1     Init:0/1            0          2s

  # After some seconds all pods except IOM are "Running" and READY (integrated Postgresql server, integrated 
  # SMTP server). IOM is in Init-phase, which means the init-containers are currently executed.
  kubectl get pods -n iom
  NAME                                                  READY   STATUS     RESTARTS   AGE
  demo-iom-0                                            0/1     Init:1/2   0          38s
  demo-mailhog-5dd4565b98-jphkm                         1/1     Running    0          38s
  demo-postgres-7b796887fb-j4hdr                        1/1     Running    0          38s

  # The init-container executed in iom-pod is dbaccount. Log messages can be seen
  # by executing the following command. If everything works well, the last message will announce the
  # successful execution of create_dbaccount.sh script.
  kubectl logs demo-iom-0 -n iom -f -c dbaccount
  ...
  {"tenant":"company-name","environment":"system-name","logHost":"demo-iom-0","logVersion":"1.0","appName":"iom-dbaccount","appVersion":"1.6.0","logType":"script","timestamp":"2022-11-06T11:33:17+00:00","level":"INFO","processName":"create_dbaccount.sh","message":"success","configName":null}

  # When init-container is finished successfully, the iom-pod is now in "Running" state, too. But it is not "READY"
  # yet. Now the IOM database is set up, applications and project customizations are deployed into the Wildfly application server.
  kubectl get pods -n iom
  NAME                                                  READY   STATUS    RESTARTS   AGE
  demo-iom-0                                            0/1     Running   0          1m50s
  demo-mailhog-5dd4565b98-jphkm                         1/1     Running   0          1m50s
  demo-postgres-7b796887fb-j4hdr                        1/1     Running   0          1m50s

  # When all pods are "Running" and "READY" the installation process of IOM is finished.
  kubectl get pods -n iom
  NAME                                                  READY   STATUS    RESTARTS   AGE
  demo-iom-0                                            1/1     Running   0          3m20s
  demo-mailhog-5dd4565b98-jphkm                         1/1     Running   0          3m20s
  demo-postgres-7b796887fb-j4hdr                        1/1     Running   0          3m20s

When all pods are *Running* and *Ready*, the installation process is finished. You should check the first terminal window, where the installation process was running.

Now the web GUI of the new IOM installation can be accessed. In fact, there are two Web GUIs, one for IOM and one for Mailhog. According to the configuration, all requests dedicated to *localhost* will be forwarded to the IOM application server, any other requests are meant for an integrated SMTP server (*Mailhog*). Open the URL https://localhost/omt in a web browser on your Mac. After accepting the self-signed certificate (the configuration did not include a valid certificate), you will see the login page of IOM. Login as *admin/!InterShop00!* to proceed.

Any other request that is not dedicated to localhost will be forwarded to *Mailhog*. To access the web-GUI of *Mailhog*, open the URL https://127.0.0.1/ in your web browser. Once again you have to accept the self-signed certificate and after that, you will see the *Mailhog* GUI.

Upgrade IOM
===========

From a Helm perspective, the rollout of any change in values or charts is an upgrade process. The process is identical, no matter if only a simple value is changed or new Docker images of a new IOM release are rolled out. The example shown here will demonstrate how to change the log-level of the *Quartz* subsystem, running in the WildFly application server.

Before the start, keep the `restrictions on upgrade <ToolsAndConcepts.rst#restrictions-on-upgrade>`_ in mind. A change of a log-level is an uncritical change that can be applied without downtime. But we have decided to use a single IOM application server only (see Requirement #8). When using a single IOM application server only, an upgrade process with downtime is inevitable. Hence, we do not have to think about the setting of parameter *downtime*.

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
     # and the integrated postgresql server are running unchanged. A few seconds after starting the
     # upgrade process, the only existing iom-pod is stopped.
     kubectl get pods -n iom
     NAME                                                  READY   STATUS        RESTARTS   AGE
     demo-iom-0                                            1/1     Terminating   0          40m
     demo-mailhog-5dd4565b98-jphkm                         1/1     Running       0          40m
     demo-postgres-7b796887fb-j4hdr                        1/1     Running       0          40m

     # After the iom-pod is terminated, a new iom-pod is started with new configuration.
     kubectl get pods -n iom
     NAME                                                  READY   STATUS     RESTARTS   AGE
     demo-iom-0                                            0/1     Running    0          56s
     demo-mailhog-5dd4565b98-jphkm                         1/1     Running    0          41m
     demo-postgres-7b796887fb-j4hdr                        1/1     Running    0          41m

     # Finally the pod is "Running" and "READY" again, which means, IOM is up again.
     kubectl get pods -n iom
     NAME                                                  READY   STATUS    RESTARTS   AGE
     demo-iom-0                                            1/1     Running   0          2m40s
     demo-mailhog-5dd4565b98-jphkm                         1/1     Running   0          46m
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
  

Since database data and shared file system of IOM were stored in local directories of the current host, they still exist after uninstalling IOM. In fact, this data represents the complete state of IOM. If we would install IOM again, with the same directories for shared file system and database data, the old IOM installation would be reincarnated.

+------------------------+-----------------+-------------------------+
|`< Back                 |`^ Up            |`Next >                  |
|<ToolsAndConcepts.rst>`_|<../README.rst>`_|<ExampleProd.rst>`_      |
+------------------------+-----------------+-------------------------+
