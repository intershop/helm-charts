+-------------------------+-----------------+--------------------------+
|`< Back                  |`^ Up            |`Next >                   |
|<ParametersMailhog.rst>`_|<../README.rst>`_|<ParametersTests.rst>`_   |
+-------------------------+-----------------+--------------------------+

================================================
Helm Charts for Intershop Order Management (IOM)
================================================

------------------------------------------
Parameters of Integrated PostgreSQL Server
------------------------------------------

+-----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|Parameter                                |Description                                                                                    |Default Value                                 |
|                                         |                                                                                               |                                              |
+=========================================+===============================================================================================+==============================================+
|postgres.enabled                         |Controls whether an integrated PostgreSQL server should be used or not. This PostgreSQL server |false                                         |
|                                         |is not intended to be used for any kind of serious IOM installation. It should only be used for|                                              |
|                                         |demo-, CI- or similar types of setups.                                                         |                                              |
+-----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.args                            |An array containing command line arguments, which are passed to the Postgres server at         |["-N", "200", "-c",                           |
|                                         |start. For more information, see the `official PostgreSQL 15 documentation                     |"max_prepared_transactions=100"]              |
|                                         |<https://www.postgresql.org/docs/15/config-setting.html#id-1.6.7.4.5>`_.                       |                                              |
+-----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.image.repository                |Repository of the PostgreSQL image. For more information, see `official Docker hub             |postgres                                      |
|                                         |<https://hub.docker.com/_/postgres>`_.                                                         |                                              |
+-----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.image.tag                       |Tag of PostgreSQL image. For more information, see `official Docker hub                        |"15"                                          |
|                                         |<https://hub.docker.com/_/postgres>`_.                                                         |                                              |
+-----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.image.pullPolicy                |Pull policy to be applied when getting PostgreSQL Docker images. For more information, see the |IfNotPresent                                  |
|                                         |`official Kubernetes documentation                                                             |                                              |
|                                         |<https://kubernetes.io/docs/concepts/containers/images/#image-pull-policy>`_.                  |                                              |
+-----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.pg                              |This group of parameters bundles the information about the superuser and default database      |                                              |
|                                         |(management database, not the IOM database).                                                   |                                              |
|                                         |                                                                                               |                                              |
|                                         |This information is used to configure the Postgres server on start, but is also used by clients|                                              |
|                                         |which require superuser access to the Postgres server. The only client that needs this kind of |                                              |
|                                         |access is the dbaccount init-image that creates/updates the IOM database.                      |                                              |
+-----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.pg.user                         |Name of the superuser. The superuser will be created when starting the Postgres server.        |postgres                                      |
|                                         |                                                                                               |                                              |
|                                         |- Ignored, if *postgres.pg.userSecretKeyRef* is defined.                                       |                                              |
+-----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.pg.userSecretKeyRef             |Instead of storing the name of the user as plain text in the values file, a reference to a key |                                              |
|                                         |within a secret can be used. For more information, see section `References to entries of       |                                              |
|                                         |Kubernetes secrets <SecretKeyRef.rst>`_.                                                       |                                              |
+-----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.pg.passwd                       |The password of the superuser. Password will be set when starting the Postgres server.         |postgres                                      |
|                                         |                                                                                               |                                              |
|                                         |- Ignored, if *postgres.pg.passwdSecretKeyRef* is defined.                                     |                                              |
+-----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.pg.passwdSecretKeyRef           |Instead of storing the password as plain text in the values file, a reference to a key within a|                                              |
|                                         |secret can be used. For more information, see section `References to entries of Kubernetes     |                                              |
|                                         |secrets`_.                                                                                     |                                              |
+-----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.pg.db                           |Name of default (management) database which will be created when starting the Postgres server. |postgres                                      |
+-----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.persistence                     |Parameters of group *postgres.persistence* are controlling if and how the database data are    |                                              |
|                                         |persisted.                                                                                     |                                              |
|                                         |                                                                                               |                                              |
|                                         |The document about usage of `Persistent Storage <PersistentStorage.rst>`_ is in general valid  |                                              |
|                                         |for PostgreSQL persistent-storage too.                                                         |                                              |
+-----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.persistence.enabled             |If set to false, data of the PostgreSQL server are not persisted at all. They are only written |false                                         |
|                                         |to memory and get lost if the Postgres pod ends.                                               |                                              |
+-----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.persistence.storageSize         |Requested storage size. For more information, see the `official Kubernetes documentation on    |20Gi                                          |
|                                         |storage <https://kubernetes.io/docs/concepts/storage/persistent-volumes/>`_.                   |                                              |
+-----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.persistence.provisioning        |Controls the provisioning method to be used. Currently three different methods of provisioning |dynamic                                       |
|                                         |are supported:                                                                                 |                                              |
|                                         |                                                                                               |                                              |
|                                         |- *dnamic*                                                                                     |                                              |
|                                         |- *static*                                                                                     |                                              |
|                                         |- *local*                                                                                      |                                              |
|                                         |                                                                                               |                                              |
|                                         |For more information see the description of according parameter-groups and the documentation   |                                              |
|                                         |about usage of `Persistent Storage <PersistentStorage.rst>`_.                                  |                                              |
+-----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.persistence.dynamic             |Parameter-group, that bundles all configuration settings of *dynamic* provisioning of          |                                              |
|                                         |persistent storage for PostgreSQL data-storage.                                                |                                              |
+-----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.persistence.dynamic.storageClass|Name of the storage class to be used for dynamic provisioning of PostgreSQLs data-storage.     |azurefile                                     |
|                                         |                                                                                               |                                              |
|                                         |- Ignored, if *postgres.persistence.provisioning* is set to an other value than *dynamic*.     |                                              |
+-----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.persistence.dynamic.annotations |Annotations of *persistence-volume-claim* to be created. The default-value prevents automatic  |"helm.sh/resource-policy": keep               |
|                                         |deletion of the *persistent-volume-claim* after deletion of IOM Helm release. See              |                                              |
|                                         |https://helm.sh/docs/topics/charts_hooks/ for more information.                                |                                              |
|                                         |                                                                                               |                                              |
|                                         |- Ignored if *postgres.persistence.provisioning* is set to an other value than *dynamic*       |                                              |
+-----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.persistence.static              |Parameter-group, that bundles all configuration settings of *static* provisioning of persistent|                                              |
|                                         |storage for PostgreSQL data-storage.                                                           |                                              |
+-----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.persistence.static.storageClass |Name of storage class, that belongs to the *persistent-volume* defined by                      |                                              |
|                                         |*postgres.persistence.static.pv*.                                                              |                                              |
|                                         |                                                                                               |                                              |
|                                         |- Ignored if *postgres.persistence.provisioning* is set to an other value than *static*.       |                                              |
+-----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.persistence.static.pv           |Name of *persistent-volume* to be used for static provisioning of PostgreSQLs data-storage. The|                                              |
|                                         |*persistent-volume* has to be created by a cluster-admin in advance.                           |                                              |
|                                         |                                                                                               |                                              |
|                                         |- Ignored if *postgres.persistence.provisioning* is set to an other value than *static*.       |                                              |
+-----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.persistence.static.annotations  |Annotations of *persistence-volume-claim* to be created.                                       |                                              |
|                                         |                                                                                               |                                              |
|                                         |- Ignored if *postgres.persistence.provisioning* is set to an other value than *static*.       |                                              |
+-----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.persistence.local               |Parameter-group, that bundles all configuration settings of *local* provisioning of persistent |                                              |
|                                         |storage for shared file-system of IOM.                                                         |                                              |
+-----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.persistence.local.hostPath      |For very simple installations, persistent data can be stored directly at a local disk. In this |                                              |
|                                         |case, the path on local host has to be stored at this parameter.                               |                                              |
|                                         |                                                                                               |                                              |
|                                         |- Ignored if *persistence.provisioning* is set to an other value than *local*.                 |                                              |
+-----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.persistence.local.reclaimPolicy |*Reclaim-policy* to be used by the *persistent-volume*. Allowed values are *Delete* and        |Delete                                        |
|                                         |*Retain*.                                                                                      |                                              |
|                                         |                                                                                               |                                              |
|                                         |- Ignored if *persistence.provisioning* is set to an other value than *local*.                 |                                              |
+-----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.persistence.local.annotations   |Annotations of *persistence-volume-claim* to be created.                                       |                                              |
|                                         |                                                                                               |                                              |
|                                         |- Ignored if *persistence.provisioning* is set to an other value than *local*.                 |                                              |
+-----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.resources                       |Resource requests & limits.                                                                    |{}                                            |
+-----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.imagePullSecrets                |List of the secrets to get credentials from.                                                   |[]                                            |
+-----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.nameOverride                    |Overwrites chart name.                                                                         |                                              |
+-----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.fullnameOverride                |Overwrites complete name, constructed from release, and chart name.                            |                                              |
+-----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.nodeSelector                    |Node labels for pod assignment.                                                                |{}                                            |
+-----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.tolerations                     |Node taints to tolerate (requires Kubernetes >=1.6).                                           |[]                                            |
+-----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.affinity                        |Node/pod affinities (requires Kubernetes >=1.6).                                               |{}                                            |
+-----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+

+-------------------------+-----------------+--------------------------+
|`< Back                  |`^ Up            |`Next >                   |
|<ParametersMailhog.rst>`_|<../README.rst>`_|<ParametersTests.rst>`_   |
+-------------------------+-----------------+--------------------------+
