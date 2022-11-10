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

+----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|Parameter                               |Description                                                                                    |Default Value                                 |
|                                        |                                                                                               |                                              |
+========================================+===============================================================================================+==============================================+
|postgres.enabled                        |Controls whether an integrated PostgreSQL server should be used or not. This PostgreSQL server |false                                         |
|                                        |is not intended to be used for any kind of serious IOM installation. It should only be used for|                                              |
|                                        |demo-, CI- or similar types of setups.                                                         |                                              |
+----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.args                           |An array containing command line arguments, which are passed to the Postgres server at         |["-N", "200", "-c",                           |
|                                        |start. For more information, see the `official PostgreSQL 12 documentation                     |"max_prepared_transactions=100"]              |
|                                        |<https://www.postgresql.org/docs/12/config-setting.html#id-1.6.6.4.5>`_.                       |                                              |
+----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.image.repository               |Repository of the PostgreSQL image. For more information, see `official Docker hub             |postgres                                      |
|                                        |<https://hub.docker.com/_/postgres>`_.                                                         |                                              |
+----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.image.tag                      |Tag of PostgreSQL image. For more information, see `official Docker hub                        |"12"                                          |
|                                        |<https://hub.docker.com/_/postgres>`_.                                                         |                                              |
+----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.image.pullPolicy               |Pull policy to be applied when getting PostgreSQL Docker images. For more information, see the |IfNotPresent                                  |
|                                        |`official Kubernetes documentation                                                             |                                              |
|                                        |<https://kubernetes.io/docs/concepts/containers/images/#image-pull-policy>`_.                  |                                              |
+----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.pg                             |This group of parameters bundles the information about the superuser and default database      |                                              |
|                                        |(management database, not the IOM database).                                                   |                                              |
|                                        |                                                                                               |                                              |
|                                        |This information is used to configure the Postgres server on start, but is also used by clients|                                              |
|                                        |which require superuser access to the Postgres server. The only client that needs this kind of |                                              |
|                                        |access is the dbaccount init-image that creates/updates the IOM database.                      |                                              |
+----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.pg.user                        |Name of the superuser. The superuser will be created when starting the Postgres server.        |postgres                                      |
|                                        |                                                                                               |                                              |
|                                        |* Ignored, if *postgres.pg.userSecretKeyRef* is defined.                                       |                                              |
+----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.pg.userSecretKeyRef            |Instead of storing the name of the user as plain text in the values file, a reference to a key |                                              |
|                                        |within a secret can be used. For more information, see section `References to entries of       |                                              |
|                                        |Kubernetes secrets <SecretKeyRef.rst>`_.                                                       |                                              |
+----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.pg.passwd                      |The password of the superuser. Password will be set when starting the Postgres server.         |postgres                                      |
|                                        |                                                                                               |                                              |
|                                        |* Ignored, if *postgres.pg.passwdSecretKeyRef* is defined.                                     |                                              |
+----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.pg.passwdSecretKeyRef          |Instead of storing the password as plain text in the values file, a reference to a key within a|                                              |
|                                        |secret can be used. For more information, see section `References to entries of Kubernetes     |                                              |
|                                        |secrets`_.                                                                                     |                                              |
+----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.pg.db                          |Name of default (management) database which will be created when starting the Postgres server. |postgres                                      |
|                                        |                                                                                               |                                              |
+----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.persistence                    |Parameters of group *postgres.persistence* are controlling if and how the database data are    |                                              |
|                                        |persisted.                                                                                     |                                              |
+----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.persistence.enabled            |If set to false, data of the PostgreSQL server are not persisted at all. They are only written |false                                         |
|                                        |to memory and get lost if the Postgres pod ends.                                               |                                              |
+----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.persistence.accessMode         |The default value allows binding the persistent volume in read/write mode to a single pod only,|ReadWriteOnce                                 |
|                                        |which is exactly what should be done for the PostgreSQL server. For more information, see the  |                                              |
|                                        |`official Kubernetes documentation on storage                                                  |                                              |
|                                        |<https://kubernetes.io/docs/concepts/storage/persistent-volumes/>`_.                           |                                              |
|                                        |                                                                                               |                                              |
|                                        |* Ignored if *postgres.persistence.hostPath* is set.                                           |                                              |
+----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.persistence.storageClass       |Name of existing storage class to be used by the PostgreSQL server.                            |                                              |
|                                        |                                                                                               |                                              |
|                                        |* Ignored if *postgres.persistence.hostPath* is set.                                           |                                              |
+----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.persistence.annotations        |Annotations to be added to the according PersistentVolumeClaim. For more information, see the  |{}                                            |
|                                        |`official Kubernetes documentation on storage                                                  |                                              |
|                                        |<https://kubernetes.io/docs/concepts/storage/persistent-volumes/>`_.                           |                                              |
|                                        |                                                                                               |                                              |
|                                        |* Ignored if *postgres.persistence.hostPath* is set.                                           |                                              |
+----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.persistence.storageSize        |Requested storage size. For more information, see the `official Kubernetes documentation on    |20Gi                                          |
|                                        |storage <https://kubernetes.io/docs/concepts/storage/persistent-volumes/>`_.                   |                                              |
+----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.persistence.hostPath           |For very simple installations, persistent data can be directly stored at a local disk. In this |                                              |
|                                        |case, the path on local host has to be stored at this parameter.                               |                                              |
+----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.resources                      |Resource requests & limits.                                                                    |{}                                            |
|                                        |                                                                                               |                                              |
+----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.imagePullSecrets               |List of the secrets to get credentials from.                                                   |[]                                            |
|                                        |                                                                                               |                                              |
+----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.nameOverride                   |Overwrites chart name.                                                                         |                                              |
|                                        |                                                                                               |                                              |
+----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.fullnameOverride               |Overwrites complete name, constructed from release, and chart name.                            |                                              |
|                                        |                                                                                               |                                              |
+----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.nodeSelector                   |Node labels for pod assignment.                                                                |{}                                            |
|                                        |                                                                                               |                                              |
+----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.tolerations                    |Node taints to tolerate (requires Kubernetes >=1.6).                                           |[]                                            |
|                                        |                                                                                               |                                              |
+----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|postgres.affinity                       |Node/pod affinities (requires Kubernetes >=1.6).                                               |{}                                            |
|                                        |                                                                                               |                                              |
+----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+

+-------------------------+-----------------+--------------------------+
|`< Back                  |`^ Up            |`Next >                   |
|<ParametersNGINX.rst>`_  |<../README.rst>`_|<ParametersTests.rst>`_   |
+-------------------------+-----------------+--------------------------+
