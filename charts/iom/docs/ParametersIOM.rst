+-------------------+-----------------+-------------------------+
|`< Back            |`^ Up            |`Next >                  |
|<ExampleProd.rst>`_|<../README.rst>`_|<ParametersMailhog.rst>`_|
+-------------------+-----------------+-------------------------+

================================================
Helm Charts for Intershop Order Management (IOM)
================================================

----------------------------
Parameters of IOM Helm Chart
----------------------------

+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|Parameter                               |Description                                                                                     |Default Value                                            |
|                                        |                                                                                                |                                                         |
+========================================+================================================================================================+=========================================================+
|replicaCount                            |The number of IOM application server instances to run in parallel.                              |2                                                        |
|                                        |                                                                                                |                                                         |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|downtime                                |The *downtime* parameter is a very critical one. Its goal and behavior is already described in  |true                                                     |
|                                        |`Restrictions on Upgrade <ToolsAndConcepts.rst#restrictions-on-upgrade>`_.                      |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |Additional information:                                                                         |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* For the *downtime* parameter to work correctly, the ``--wait`` and                            |                                                         |
|                                        |  ``--timeout`` command line parameters must always be set when running Helm.                   |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|image.repository                        |Repository of the IOM app product/project image.                                                |docker.tools.intershop.com/iom/intershophub/iom          |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|image.pullPolicy                        |Pull policy, to be applied when getting IOM product/project Docker image. For more information, |IfNotPresent                                             |
|                                        |see the `official Kubernetes documentation                                                      |                                                         |
|                                        |<https://kubernetes.io/docs/concepts/containers/images/#image-pull-policy>`_.                   |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|image.tag                               |The tag of IOM product/project image.                                                           |4.8.0                                                    |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|dbaccount                               |Parameters bundled by dbaccount are used to control the dbaccount init-container which creates  |                                                         |
|                                        |the IOM database-user and the IOM database itself. To enable the dbaccount init-container to do |                                                         |
|                                        |this, it needs to get superuser access to the PostgreSQL server and it requires the according   |                                                         |
|                                        |information about the IOM database. This information is not contained in dbaccount              |                                                         |
|                                        |parameters. Instead, the general connection and superuser information are retrieved from *pg* or|                                                         |
|                                        |*postgres.pg* parameters (depending on *postgres.enabled*). All information about the IOM       |                                                         |
|                                        |database user and database are provided by *oms.db* parameters.                                 |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |Once the IOM database is created, the dbaccount init-container is not needed any longer. Hence, |                                                         |
|                                        |all IOM installations, except really non-critical demo- and CI-setups, should enable dbaccount  |                                                         |
|                                        |init-container only temporarily to initialize the database account.                             |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|dbaccount.enabled                       |Controls if the dbaccount init-container should be executed or not. If enabled, dbaccount will  |false                                                    |
|                                        |only be executed when installing IOM, not on upgrade operations.                                |                                                         |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|dbaccount.image.repository              |Repository of the dbaccount image.                                                              |docker.tools.intershop.com/iom/intershophub/iom-dbaccount|
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|dbaccount.image.pullPolicy              |Pull policy, to be applied when getting dbaccount Docker image. For more information, see the   |IfNotPresent                                             |
|                                        |`official Kubernetes documentation                                                              |                                                         |
|                                        |<https://kubernetes.io/docs/concepts/containers/images/#image-pull-policy>`_.                   |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|dbaccount.image.tag                     |The tag of dbaccount image.                                                                     |2.0.0                                                    |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|dbaccount.resetData                     |Controls if dbaccount init-container should reset an already existing IOM database during the   |false                                                    |
|                                        |installation process of IOM. If set to *true*, existing data is deleted without backup and      |                                                         |
|                                        |further warning.                                                                                |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Deprecated since IOM Helm charts 3.0.0. Replaced by *oms.db.resetData*. Will be removed in    |                                                         |
|                                        |  a future version.                                                                             |                                                         |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|dbaccount.options                       |When creating the IOM database, more options added to OWNER are required. Depending on the      |"ENCODING='UTF8' LC_COLLATE='en_US.utf8'                 |
|                                        |configuration of the PostgreSQL server, these options may differ. The default values can be used|LC_CTYPE='en_US.utf8' CONNECTION LIMIT=-1                |
|                                        |as they are for integrated PostgreSQL server, for Azure Database for PostgreSQL service, and for|TEMPLATE=template0"                                      |
|                                        |most other servers, too.                                                                        |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |See `Options and Requirements of IOM database <IOMDatabase.rst>`_ for details.                  |                                                         |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|dbaccount.searchPath                    |In some circumstances, the search path for database objects has to be extended. This is the case|                                                         |
|                                        |if custom schemas are used for customizations or tests. To add more schemas to the search-path, |                                                         |
|                                        |set the current parameter to a string containing all additional schemas, separated by a comma,  |                                                         |
|                                        |e.g. "tests, customschema". The additional entries are inserted at the beginning of the         |                                                         |
|                                        |search-path, hence objects with the same name as standard objects of IOM are found first.       |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|dbaccount.tablespace                    |Use the passed tablespace as default for IOM database users and IOM database. Tablespace has to |                                                         |
|                                        |exist, it will not be created.                                                                  |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |`Options and Requirements of IOM database`_ will give you some more information.                |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Ignored if *postgres.enabled* is *true*, since the integrated PostgreSQL                      |                                                         |
|                                        |  server can never create a custom tablespace prior to the initialization of the                |                                                         |
|                                        |  IOM database user and IOM database.                                                           |                                                         |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|dbaccount.resources                     |Resource requests & limits.                                                                     |{}                                                       |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|pg                                      |This group of parameters bundles the information required to connect the PostgreSQL server,     |                                                         |
|                                        |information about the superuser, and default database (management database, not the IOM         |                                                         |
|                                        |database).                                                                                      |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |Not all clients need all information:                                                           |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |The dbaccount init-container is the only client that needs access to the PostgreSQL server as a |                                                         |
|                                        |superuser. Hence, if you do not enable dbaccount, the parameters *pg.user(SecretKeyRef)*,       |                                                         |
|                                        |*pg.passwd(SecretKeyRef)* and *pg.db* should not be set at all.                                 |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |If integrated PostgreSQL server is enabled (*postgres.enabled* set to *true*), all parameters   |                                                         |
|                                        |defined by *pg* are ignored completely. In this case, parameters defined by *postgres.pg* are   |                                                         |
|                                        |used instead.                                                                                   |                                                         |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|pg.user                                 |Name of the superuser.                                                                          |postgres                                                 |
|                                        |                                                                                                |                                                         |
|                                        |* Required only if *dbaccount.enabled* is set to *true*.                                        |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Ignored if *postgres.enabled* is set to *true*.                                               |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Ignored if *pg.userSecretKeyRef* is set.                                                      |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|pg.userSecretKeyRef                     |Instead of storing the name of the user as plain text in the values file, a reference to a key  |                                                         |
|                                        |within a secret can be used. For more information, see `References to entries of Kubernetes     |                                                         |
|                                        |secrets <SecretKeyRef.rst>`_.                                                                   |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Required only if *dbaccount.enabled* is set to *true* and *pg.user* is not set.               |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Ignored if *postgres.enabled* is set to *true*.                                               |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|pg.passwd                               |The password of the superuser.                                                                  |postgres                                                 |
|                                        |                                                                                                |                                                         |
|                                        |* Required only if *dbaccount.enabled* is set to *true*.                                        |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Ignored if *postgres.enabled* is set to *true*.                                               |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Ignored if *pg.passwdSecretKeyRef* is set.                                                    |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|pg.passwdSecretKeyRef                   |Instead of storing the password as plain text in the values file, a reference to a key within a |                                                         |
|                                        |secret can be used. For more information, see `References to entries of Kubernetes secrets`_.   |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Required only if *dbaccount.enabled* is set to *true* and *pg.passwd* is not set.             |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Ignored if *postgres.enabled* is set to *true*.                                               |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|pg.db                                   |Name of the default (management) database.                                                      |postgres                                                 |
|                                        |                                                                                                |                                                         |
|                                        |* Required only if *dbaccount.enabled* is set to *true*.                                        |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Ignored if *postgres.enabled* is set to *true*.                                               |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|pg.host                                 |The hostname of the PostgreSQL server.                                                          |postgres-service                                         |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|pg.port                                 |Port of the PostgreSQL server.                                                                  |"5432"                                                   |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|pg.userConnectionSuffix                 |When using the Azure Database for PostgreSQL service, user names have to be extended by a       |                                                         |
|                                        |suffix, beginning with '@'. For more information, refer to the `official Azure Database for     |                                                         |
|                                        |PostgreSQL documentation                                                                        |                                                         |
|                                        |<https://docs.microsoft.com/en-us/azure/postgresql/connect-java#get-connection-information>`_.  |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |This suffix is not a part of the user name. It has to be used only when connecting to the       |                                                         |
|                                        |database. For this reason, the parameter *pg.userConnectionSuffix* was separated from *pg.user* |                                                         |
|                                        |and *oms.db.user*.                                                                              |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |Example: "@mydemoserver"                                                                        |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|pg.sslMode                              |*pg.sslMode* has to contain one of the following values: *disable*, *allow*, *prefer*,          |prefer                                                   |
|                                        |*require*, *verify-ca*, *verify-full*. For a detailed description of settings, please see `the  |                                                         |
|                                        |official PostgreSQL documentation                                                               |                                                         |
|                                        |<https://www.postgresql.org/docs/12/libpq-connect.html#LIBPQ-CONNSTRING>`_.                     |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|pg.sslCompression                       |If set to "1", data sent over SSL connections will be compressed. If set to "0", compression    |"0"                                                      |
|                                        |will be disabled. For a detailed description, please see the `official PostgreSQL documentation |                                                         |
|                                        |<https://www.postgresql.org/docs/12/libpq-connect.html#LIBPQ-CONNSTRING>`_.                     |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|pg.sslRootCert                          |Azure Database for PostgreSQL service might require verification of the server certificate, see |                                                         |
|                                        |the document `SSL configuration in official Azure Database for PostgreSQL documentation         |                                                         |
|                                        |<https://docs.microsoft.com/en-us/azure/postgresql/concepts-ssl-connection-security>`_.  To     |                                                         |
|                                        |handle this case, it is possible to pass the SSL root certificate in *pg.sslRootCert*.          |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|oms                                     |Parameters of group *oms* are all related to the configuration of IOM.                          |                                                         |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|oms.publicUrl                           |The publicly accessible base URL of IOM which could be the DNS name of the load balancer,       |https://localhost                                        |
|                                        |etc. It is used internally for link generation.                                                 |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|oms.jwtSecret                           |The shared secret for `JSON Web Token <https://jwt.io/>`_ (JWT) creation/validation. JWTs will  |                                                         |
|                                        |be generated with the HMAC algorithm (HS256).                                                   |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |To secure the JWT, a key of the same size as the hash output or larger must be used with the    |                                                         |
|                                        |JWS HMAC SHA-2 algorithms (i.e, 256 bits for "HS256"), see `JSON Web Algorithms (JWA) |         |                                                         |
|                                        |3.2. HMAC with SHA-2 Functions <https://tools.ietf.org/html/rfc7518#section-3.2>`_.             |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |If left empty AND *oms.jwtSecretKeyRef* is empty too, a secret with random value is created and |                                                         |
|                                        |used automatically.                                                                             |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Ignored if *oms.jwtSecretKeyRef* is set.                                                      |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|oms.jwtSecretKeyRef                     |Instead of storing the JWT secret as plain text in the values file, a reference to a key within |                                                         |
|                                        |a secret can be used. For more information, see `References to entries of Kubernetes            |                                                         |
|                                        |secrets`_.                                                                                      |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |If left empty AND *oms.jwtSecret* is empty too, a secret with random value is created and used  |                                                         |
|                                        |automatically.                                                                                  |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|oms.archiveOrderMessageLogMinAge        |Number of days after which the entries in table "OrderMessageLogDO" should be exported and the  |"90"                                                     |
|                                        |columns "request" and "response" set to 'archived' in order to reduce the table size.           |                                                         |
|                                        |Min. accepted value: 10                                                                         |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |Exported data are stored under *share/archive*.                                                 |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Value has to match ``^[1-9]([0-9]+)?``                                                        |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|oms.deleteOrderMessageLogMinAge         |Number of days after which the entries in table "OrderMessageLogDO" will definitely be deleted  |"180"                                                    |
|                                        |in order to reduce the table size. Must be greater than *oms.archiveOrderMessageLogMinAge*.     |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Value has to match ``^[1-9]([0-9]+)?``                                                        |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|oms.archiveShopCustomerMailMinAge       |Number of days after which the entries in table "ShopCustomerMailTransmissionDO" should be      |"1826"                                                   |
|                                        |exported (Quartz job "ShopCustomerMailTransmissionArchive") and the column "message" set to     |                                                         |
|                                        |'deleted' in order to reduce the table size. Default is 1826 for 5 years. However, the export   |                                                         |
|                                        |will not take place if this property and *oms.archiveShopCustomerMailMaxCount* are not          |                                                         |
|                                        |set. Min. accepted value: 10                                                                    |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |Exported data are stored under *share/archive*.                                                 |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Value has to match ``^[1-9]([0-9]+)$``                                                        |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|oms.archiveShopCustomerMailMaxCount     |Maximum number of entries in table "ShopCustomerMailTransmissionDO" to be exported per run of   |"10000"                                                  |
|                                        |the Quartz job "ShopCustomerMailTransmissionArchive". Default is 10000, however, the export will|                                                         |
|                                        |not take place if this property and *oms.archiveShopCustomerMailMinAge* are not set.            |                                                         |
|                                        |Min. accepted value: 10                                                                         |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Value has to match ``^[1-9]([0-9]+)$``                                                        |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|oms.deleteShopCustomerMailMinAge        |The number of days after which the entries in table "ShopCustomerMailTransmissionDO" will       |"2190"                                                   |
|                                        |definitely be deleted in order to reduce the table size (Quartz job                             |                                                         |
|                                        |"ShopCustomerMailTransmissionArchive"). Default is 2190 for 6 years. However, the deletion will |                                                         |
|                                        |not take place if this property is not set.                                                     |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Value has to match ``^[1-9]([0-9]+)$``                                                        |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|oms.secureCookiesEnabled                |If set to *true*, cookies will be sent with secure flag. In this case OMT requires fully        |true                                                     |
|                                        |encrypted HTTP traffic in order to work properly.                                               |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|oms.execBackendApps                     |If set to *false*, no backend applications will be executed in the current cluster. This is     |true                                                     |
|                                        |required by transregional installations of IOM only, where many local IOM clusters have to work |                                                         |
|                                        |together. In this case, only one of the clusters must execute backend applications.             |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|oms.db                                  |Group *oms.db* bundles all parameters which are required to access the IOM database. General    |                                                         |
|                                        |information required to connect the PostgreSQL server are stored at group *pg*.                 |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|oms.db.name                             |The name of the IOM database.                                                                   |oms_db                                                   |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|oms.db.user                             |The IOM database user.                                                                          |oms_user                                                 |
|                                        |                                                                                                |                                                         |
|                                        |* Ignored if *oms.db.userSecretKeyRef* is set.                                                  |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|oms.db.userSecretKeyRef                 |Instead of storing the name of the user as plain text in the values file, a reference to a key  |                                                         |
|                                        |within a secret can be used. For more information, see `References to entries of Kubernetes     |                                                         |
|                                        |secrets`_.                                                                                      |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Only required if *oms.db.user* is not set.                                                    |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|oms.db.passwd                           |The password of the IOM database user.                                                          |OmsDB                                                    |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|oms.db.passwdSecretKeyRef               |Instead of storing the password as plain text in the values file, a reference to a key within a |                                                         |
|                                        |secret can be used. For more information, see `References to entries of Kubernetes secrets`_.   |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Only required if *oms.db.passwd* is not set.                                                  |                                                         |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|oms.db.hostlist                         |A comma-separated list of database servers. Each server entry consists of a hostname and port,  |                                                         |
|                                        |separated by a colon. Setting the port is optional. If not set, standard port 5432 will be used.|                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Only required if a high availability cluster of PostgreSQL servers is used, to list all       |                                                         |
|                                        |  possible connecting possibilities to this cluster.                                            |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Affects IOM application servers only. dbaccount-image is using connection information from    |                                                         |
|                                        |  *pg* parameters group only. The same is true for the IOM application server if                |                                                         |
|                                        |  *oms.db.hostlist* is empty.                                                                   |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|oms.db.connectionMonitor                |Parameters in *oms.db.connectionMonitor* are dedicated to control a Kubernetes cronjob that is  |                                                         |
|                                        |writing *INFO* log messages created by process ``connection_monitor.sh`` that provide           |                                                         |
|                                        |information about database clients and the number of connections they are using. This           |                                                         |
|                                        |information is written in CSV format with quoted newlines between records.                      |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |Example:                                                                                        |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |``{"tenant":"company-name","environment":"system-name",                                         |                                                         |
|                                        |"logHost":"ci-iom-connection-monitor-27154801-c6lk4","logVersion":"1.0",                        |                                                         |
|                                        |"appName":"iom","appVersion":"4.5.0","logType":"script",                                        |                                                         |
|                                        |"timestamp":"2023-08-18T12:01:01+00:00","level":"INFO",                                         |                                                         |
|                                        |"processName":"connection_monitor.sh","message":                                                |                                                         |
|                                        |"count,application_name,client_addr\\n51,OMS_ci-iom-0,40.67.249.40\\n2,psql,40.67.249.40",      |                                                         |
|                                        |"configName":null}``                                                                            |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |``connection_monitor.sh`` ignores settings of parameter *log.level.scripts*. It always uses log |                                                         |
|                                        |level *INFO*.                                                                                   |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|oms.db.connectionMonitor.enabled        |Enables/disables Kubernetes cronjob providing the connection monitoring messages.               |false                                                    |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|oms.db.connectionMonitor.schedule       |Controls frequency of Kubernetes cronjob providing the connection monitoring messages.          |"\*/1 \* \* \* \*"                                       |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|oms.db.connectTimeout                   |Controls connect timeout of database connections (jdbc- and psql-initiated connections). Value  |10                                                       |
|                                        |is defined in seconds. A value of 0 means to wait infinitely.                                   |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Requires dbaccount 1.3.0.0 or newer                                                           |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|oms.db.resetData                        |Controls if an already existing IOM database should be reset during the installation process of |false                                                    |
|                                        |IOM. If set to *true*, existing data is deleted without backup and further warning.             |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Requires IOM 5.0.0 or newer.                                                                  |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Replaces parameter *dbaccount.resetData*.                                                     |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|oms.sso                                 |Parameters in *oms.sso* are bundling the configuration of *single sign-on* (SSO)                |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Requires IOM 4.3.0 or newer                                                                   |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|oms.sso.enabled                         |Enables/disables *single sign-on*                                                               |false                                                    |
|                                        |                                                                                                |                                                         |
|                                        |* Requires IOM 4.3.0 or newer                                                                   |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|oms.sso.type                            |Defines the type of *single sign-on* to be used. Allowed values are *azure-ad* and *keycloak*.  |azure-ad                                                 |
|                                        |                                                                                                |                                                         |
|                                        |* Requires IOM 4.3.0 or newer                                                                   |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|oms.sso.oidcConfig                      |Defines the configuration of *single sign-on*. The value is a JSON structure similar to         |                                                         |
|                                        |*oidc.json*. See `Elytron OpenID Connect Client Subsystem Configuration                         |                                                         |
|                                        |<https://docs.wildfly.org/26/Admin_Guide.html#Elytron_OIDC_Client>`_. The value has to be passed|                                                         |
|                                        |as a string value.                                                                              |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |Example:                                                                                        |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |.. code-block:: yaml                                                                            |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |  sso:                                                                                          |                                                         |
|                                        |    oidcConfig: |                                                                               |                                                         |
|                                        |      { "client-id": "abc",                                                                     |                                                         |
|                                        |        "credentials": {                                                                        |                                                         |
|                                        |          "secret": "def"                                                                       |                                                         |
|                                        |        },                                                                                      |                                                         |
|                                        |        "provider-url": "https://login.provider",                                               |                                                         |
|                                        |        "public-client": "false",                                                               |                                                         |
|                                        |        "ssl-required": "EXTERNAL"                                                              |                                                         |
|                                        |      }                                                                                         |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Requires IOM 4.3.0 or newer                                                                   |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|oms.sso.oidcConfigSecretKeyRef          |Instead of storing the OIDC configuration as plain text in the values file, a reference to a key|{}                                                       |
|                                        |within a *Kubernetes Secret* can be used. For more information, see `References to Kubernetes   |                                                         |
|                                        |secrets <SecretKeyRef.rst>`_.                                                                   |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Requires IOM 4.3.0 or newer                                                                   |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|oms.smtp                                |Parameters in *oms.smtp* are bundling the information required to connect SMTP server.          |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |If an integrated SMTP server is enabled (*mailhog.enabled* set to *true*), all parameters       |                                                         |
|                                        |defined by *oms.smtp* are ignored completely. In this case, IOM will be automatically configured|                                                         |
|                                        |to use the integrated SMTP server.                                                              |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|oms.smtp.host                           |The hostname of the mail server IOM uses to send e-mails.                                       |mail-service                                             |
|                                        |                                                                                                |                                                         |
|                                        |* Ignored if *mailhog.enabled* is set to *true*.                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|oms.smtp.port                           |The port of the mail server IOM uses to send e-mails.                                           |"1025"                                                   |
|                                        |                                                                                                |                                                         |
|                                        |* Ignored if *mailhog.enabled* is set to *true*.                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|oms.smtp.user                           |The user name for mail server authentication.                                                   |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Only required if the SMTP server requires authentication.                                     |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Ignored if *mailhog.enabled* is set to *true*.                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|oms.smtp.userSecretKeyRef               |Instead of storing the user name as plain text in the values file, a reference to a key within a|                                                         |
|                                        |secret can be used. For more information, see `References to entries of Kubernetes secrets`_.   |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Only required if *oms.smtp.user* is not set and the SMTP server requires authentication.      |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Ignored if *mailhog.enabled* is set to *true*.                                                |                                                         |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|oms.smtp.passwd                         |The password for mail server authentication.                                                    |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Only required if the SMTP server requires authentication.                                     |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Ignored if *mailhog.enabled* is set to *true*.                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|oms.smtp.passwdSecretKeyRef             |Instead of storing the password as plain text in the values file, a reference to a key within a |                                                         |
|                                        |secret can be used. For more information, see `References to entries of Kubernetes secrets`_.   |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Only required if *oms.smtp.passwd* is not set and the SMTP server requires authentication.    |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Ignored if *mailhog.enabled* is set to *true*.                                                |                                                         |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|startupProbe                            |Group of parameters to fine-tune the startup probe of Kubernetes. The basic kind of probe is    |                                                         |
|                                        |fixed and cannot be changed. For an overview of probes and pod lifecycle, see the `official     |                                                         |
|                                        |Kubernetes documentation on Pod-Lifecycle                                                       |                                                         |
|                                        |<https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#types-of-probe>`_.           |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |The startup probe must be used to observe all the tasks (create db account, roll out dump,      |                                                         |
|                                        |execute stored procedures, run database migrations, apply project configuration) that are done  |                                                         |
|                                        |before the Wildfly application server is started. The startup probe must not finally fail before|                                                         |
|                                        |the end of the startup phase, otherwise the pod will be ended and restarted. The startup phase  |                                                         |
|                                        |ends when the startup probe succeeds. To do so, you need to configure startupProbe in such a way|                                                         |
|                                        |that                                                                                            |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |  *initialDelaySeconds + periodSeconds * failureThreshold*                                      |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |is larger than the time needed for the startup phase! The default values provided by IOM Helm   |                                                         |
|                                        |charts provide a 1 hour time frame for the startup phase: 60s + 10s * 354 = 3600s = 1h. If your |                                                         |
|                                        |system needs more time for the startup phase, you have to adapt the parameters. It is           |                                                         |
|                                        |recommended to increase *startupProbe.failureThreshold* only and to leave all other parameters  |                                                         |
|                                        |unchanged.                                                                                      |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|startupProbe.enabled                    |Enables to switch on/off the startup probe.                                                     |true                                                     |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|startupProbe.periodSeconds              |How often (in seconds) to perform the probe. The minimum value is 1.                            |10                                                       |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|startupProbe.initialDelaySeconds        |Number of seconds after the container has started before startup probes are initiated. Minimum  |60                                                       |
|                                        |value is 0.                                                                                     |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|startupProbe.timeoutSeconds             |Number of seconds after which the probe times out. Default is set to 1 second. The minimum value|5                                                        |
|                                        |is 1.                                                                                           |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|startupProbe.failureThreshold           |When a probe fails, Kubernetes will try *failureThreshold* times before giving up. Giving up in |354                                                      |
|                                        |case of startup probe means restarting the container. The minimum value is 1.                   |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|livenessProbe                           |Group of parameters to fine-tune the liveness probe of Kubernetes. The basic kind of probe is   |                                                         |
|                                        |fixed and cannot be changed. For an overview of probes and pod lifecycle, see the `official     |                                                         |
|                                        |Kubernetes documentation on Pod-Lifecycle                                                       |                                                         |
|                                        |<https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#types-of-probe>`_.           |                                                         |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|livenessProbe.enabled                   |Enables to switch on/off the liveness probe.                                                    |true                                                     |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|livenessProbe.periodSeconds             |How often (in seconds) to perform the probe. The minimum value is 1.                            |10                                                       |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|livenessProbe.initialDelaySeconds       |Number of seconds after the container has started before liveness probes are initiated. Minimum |60                                                       |
|                                        |value is 0.                                                                                     |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|livenessProbe.timeoutSeconds            |Number of seconds after which the probe times out. Default is set to 1 second. The minimum value|5                                                        |
|                                        |is 1.                                                                                           |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|livenessProbe.failureThreshold          |When a probe fails, Kubernetes will try *failureThreshold* times before giving up. Giving up in |3                                                        |
|                                        |case of liveness probe means restarting the container. The minimum value is 1.                  |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|readinessProbe                          |Group of parameters to fine-tune the readiness probe of Kubernetes. The basic kind of probe is  |                                                         |
|                                        |fixed and cannot be changed. For an overview of probes and pod lifecycle, see the `official     |                                                         |
|                                        |Kubernetes documentation on Pod-Lifecycle                                                       |                                                         |
|                                        |<https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#types-of-probe>`_.           |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|readinessProbe.enabled                  |Allows to switch the readiness probe on/off.                                                    |true                                                     |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|readinessProbe.periodSeconds            |How often (in seconds) to perform the probe. The minimum value is 1.                            |10                                                       |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|readinessProbe.initialDelaySeconds      |Number of seconds after the container has started before readiness probes are initiated. The    |60                                                       |
|                                        |minimum value is 0.                                                                             |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|readinessProbe.timeoutSeconds           |Number of seconds after which the probe times out. Default is set to 1 second. The minimum value|8                                                        |
|                                        |is 1.                                                                                           |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|readinessProbe.failureThreshold         |When a probe fails, Kubernetes will try *failureThreshold* times before giving up. Giving up in |1                                                        |
|                                        |case of readiness probe means the pod will be marked as *Unready*. The minimum value is 1.      |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|readinessProbe.successThreshold         |Minimum consecutive successes for the probe to be considered successful after having            |1                                                        |
|                                        |failed. The minimum value is 1.                                                                 |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|jboss                                   |Parameters of group jboss are all related to the configuration of Wildfly/JBoss.                |                                                         |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|jboss.javaOpts                          |The value of *jboss.javaOpts* is passed to Java options of the WildFly application server.      |``"-XX:+UseContainerSupport                              |
|                                        |                                                                                                |-XX:MinRAMPercentage=85                                  |
|                                        |The default value used by Helm charts 1.5.0 and newer allows for not having to care about Java  |-XX:MaxRAMPercentage=85"``                               |
|                                        |memory settings any longer. Just set the memory size in parameter resources and the JVM will    |                                                         |
|                                        |recognize this and adapt its memory configuration to this value.                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|jboss.javaOptsAppend                    |Java options, to be passed to the application-server, are built from the two parameters         |                                                         |
|                                        |*jboss.javaOpts* and *jboss.javaOptsAppend*. It is recommended not to overwrite *jboss.javaOpts*|                                                         |
|                                        |or only to overwrite it, if really necessary. This way, the maintenance effort of your          |                                                         |
|                                        |values-file will be reduced, since it is not necessary to track changes of the default value of |                                                         |
|                                        |*jboss.javaOpts*, which has to be reapplied to the overwritten value.                           |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|jboss.opts                              |Additional command-line arguments to be used when starting the WildFly application server.      |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |Example: ``"--debug *:8787"``                                                                   |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|jboss.xaPoolsizeMin                     |The minimum value of the pool size of XA datasources.                                           |"50"                                                     |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|jboss.xaPoolsizeMax                     |The maximum value of the pool size of XA datasources.                                           |"125"                                                    |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|jboss.activemqClientPoolSizeMax         |Maximum size of the ActiveMQ client thread pool.                                                |"50"                                                     |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|jboss.nodePrefix                        |*jboss.nodePrefix* allows to define the prefix which is used to create a unique ID of the server|                                                         |
|                                        |within the cluster. For uniqueness, the prefix will be extended by the number of the pod it has |                                                         |
|                                        |as part of the stateful set.                                                                    |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |If *jboss.nodePrefix* is left empty, the hostname is used as unique ID.                         |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |There are two use cases which might make it necessary to define *jboss.nodePrefix*:             |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |1. If the hostname exceeds the length of 23 characters, it cannot be used as unique ID of the   |                                                         |
|                                        |   Wildfly application server. See `Infogix support article on wildfly not starting             |                                                         |
|                                        |   <https://support.infogix.com/hc/en-us/articles/360056492934->`_.                             |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |2. If IOM is set up as a transregional installation, which uses different Kubernetes clusters   |                                                         |
|                                        |   in different regions, it has to be guaranteed that each IOM server has its unique ID. To do  |                                                         |
|                                        |   so, every IOM cluster should use a unique value for *jboss.nodePrefix*. Alternatively, it is |                                                         |
|                                        |   also possible to use different Helm deployment names in each cluster. At least one of these  |                                                         |
|                                        |   two options **MUST** be used for a transregional installation.                               |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|log                                     |Parameters of group log are all related to the configuration of the logging of IOM.             |                                                         |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|log.access.enabled                      |Controls creation of access log messages.                                                       |true                                                     |
|                                        |                                                                                                |                                                         |
|                                        |Allowed values are: *true*, *false*.                                                            |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|log.level.scripts                       |Controls log level of all shell scripts running in one of the IOM-related containers (as defined|INFO                                                     |
|                                        |in image and dbaccount.image).                                                                  |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |Allowed values are: *ERROR*, *WARN*, *INFO*, *DEBUG*.                                           |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|log.level.iom                           |Controls log level of IOM log handler, which covers all Java packages beginning with *bakery*,  |WARN                                                     |
|                                        |*com.intershop.oms*, *com.theberlinbakery*, *org.jboss.ejb3.invocation*.                        |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |Allowed values are: *FATAL*, *ERROR*, *WARN*, *INFO*, *DEBUG*, *TRACE*, *ALL*.                  |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|log.level.hibernate                     |Controls log level of HIBERNATE log handler, which covers all Java packages beginning with      |WARN                                                     |
|                                        |*org.hibernate*.                                                                                |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |Allowed values are: *FATAL*, *ERROR*, *WARN*, *INFO*, *DEBUG*, *TRACE*, *ALL*.                  |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|log.level.quartz                        |Controls log level of QUARTZ log handler, which covers all Java packages beginning with         |WARN                                                     |
|                                        |*org.quartz*.                                                                                   |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |Allowed values are: *FATAL*, *ERROR*, *WARN*, *INFO*, *DEBUG*, *TRACE*, *ALL*.                  |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|log.level.activeMQ                      |Controls log level of ACTIVEMQ log handler, which covers all Java packages beginning with       |WARN                                                     |
|                                        |*org.apache.activemq*.                                                                          |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |Allowed values are: *FATAL*, *ERROR*, *WARN*, *INFO*, *DEBUG*, *TRACE*, *ALL*.                  |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|log.level.console                       |The CONSOLE handler has no explicit assignments of Java packages. This handler is assigned to   |WARN                                                     |
|                                        |root loggers which do not need any assignments. Instead, this log handler handles all unassigned|                                                         |
|                                        |Java packages, too.                                                                             |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |Allowed values are: *FATAL*, *ERROR*, *WARN*, *INFO*, *DEBUG*, *TRACE*, *ALL*.                  |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|log.level.customization                 |Another handler without package assignments is CUSTOMIZATION. In difference to CONSOLE, this    |WARN                                                     |
|                                        |handler will not log any messages as long as no Java packages are assigned. The assignment of   |                                                         |
|                                        |Java packages has to be done in the project configuration and is described in `Guide - IOM      |                                                         |
|                                        |Standard Project Structure <TODO>`_.                                                            |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |Allowed values are: *FATAL*, *ERROR*, *WARN*, *INFO*, *DEBUG*, *TRACE*, *ALL*.                  |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|log.metadata                            |*log.metadata* bundles parameters required to configure additional information to appear in log |                                                         |
|                                        |messages.                                                                                       |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Deprecated since IOM Helm Charts 1.3.0. According information will be injected in             |                                                         |
|                                        |  the future, without the need to loop them through IOM. Will be removed in a future version.   |                                                         |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|log.metadata.tenant                     |The name of the tenant is added to every log message.                                           |company-name                                             |
|                                        |                                                                                                |                                                         |
|                                        |Example: Intershop                                                                              |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Deprecated since IOM Helm Charts 1.3.0. According information will be injected in             |                                                         |
|                                        |  the future, without the need to loop them through IOM. Will be removed in a future version.   |                                                         |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|log.metadata.environment                |The name of the environment is added to every log message.                                      |system-name                                              |
|                                        |                                                                                                |                                                         |
|                                        |Example: production                                                                             |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Deprecated since IOM Helm Charts 1.3.0. According information will be injected in             |                                                         |
|                                        |  the future, without the need to loop them through IOM. Will be removed in a future version.   |                                                         |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|log.rest                                |This parameter can hold a list of operation IDs of REST interfaces. If the operation ID of a    |[]                                                       |
|                                        |REST interface is listed here, information about request and response of the according REST     |                                                         |
|                                        |calls is written into *DEBUG* messages. Operation IDs are part of the YAML specification of IOM |                                                         |
|                                        |REST interfaces.                                                                                |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |Example:                                                                                        |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |.. code-block:: yaml                                                                            |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |  log:                                                                                          |                                                         |
|                                        |    rest:                                                                                       |                                                         |
|                                        |      - createOrder                                                                             |                                                         |
|                                        |      - getReturnRequests                                                                       |                                                         |
|                                        |      - updateTransmissions                                                                     |                                                         |
|                                        |      - createOrderResponse                                                                     |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|podDisruptionBudget.maxUnavailable      |Defines the maximum number of unavailable IOM pods, that are allowed during a voluntary         |1                                                        |
|                                        |disruption of the Kubernetes cluster.                                                           |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|podAntiAffinity                         |Default values of *podAntiAffinity* are creating a rule, which prevents scheduling of more than |                                                         |
|                                        |one IOM pod of the current helm release onto one node. This way the IOM deployment becomes      |                                                         |
|                                        |robust against failures of a single node.                                                       |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|podAntiAffinity.enabled                 |Enables/disables *podAntiAffinity*.                                                             |true                                                     |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|podAntiAffinity.mode                    |There are two values allowed for *podAntiAffinity.mode*: *required* and *preferred*. In mode    |required                                                 |
|                                        |*required* the deployment fails, if not enough nodes are available to deploy all IOM pods. When |                                                         |
|                                        |using mode *preferred*, this kind of problem will be tolerated for the prize of lower           |                                                         |
|                                        |availability.                                                                                   |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |The behavior of the two modes is very different when using a dynamically growing Kubernetes     |                                                         |
|                                        |cluster. In mode *required* the creation of a new node is forced, if all existing nodes are     |                                                         |
|                                        |already used for the current deployment. Mode *preferred* will not enforce the creation of new  |                                                         |
|                                        |nodes in this case.                                                                             |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|podAntiAffinity.topologyKey             |*podAntyAffinity.topologyKey* defines the name of the label to be used for anti-affinity. The   |kubernetes.io/hostname                                   |
|                                        |default value *kubernetes.io/hostname* makes sure that nodes with identical values of this label|                                                         |
|                                        |cannot host more than one IOM pod of the same Helm release.                                     |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|affinity                                |Allows to define additional pod affinity rules.                                                 |{}                                                       |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|spreadPods                              |*spreadPods* provides an alternative or additional method to spread IOM pods over nodes. In     |                                                         |
|                                        |difference to *podAntiAffinity* it is possible to run more than one pod per node. E.g. if there |                                                         |
|                                        |are 2 nodes and 4 pods, the pods are evenly spread over the nodes. Each node is then running 2  |                                                         |
|                                        |pods. Additionally it is very easy to combine different topologies, since                       |                                                         |
|                                        |*topologySpreadContraints* can hold a list of constraints.                                      |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |When using a dynamically growing Kubernetes cluster, this method spreads the pods only over     |                                                         |
|                                        |already existing nodes. *spreadPods* is not enforcing the creation of new nodes. The only way to|                                                         |
|                                        |do this is the usage of *podAntiAffinity.mode: required*.                                       |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |For more information, see `Introducing PodTopologySpread                                        |                                                         |
|                                        |<https://kubernetes.io/blog/2020/05/introducing-podtopologyspread/>`_.                          |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|spreadPods.enabled                      |Enables/disabled *spreadPods*.                                                                  |false                                                    |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|spreadPods.topologySpreadConstraints    |List of constraints that will be extended with selection of IOM pods of the current Helm        |.. code-block:: yaml                                     |
|                                        |release. The default value provides an even spreading of IOM pods over existing nodes based on  |                                                         |
|                                        |hostname.                                                                                       |  - maxSkew: 1                                           |
|                                        |                                                                                                |    whenUnsatisfiable: ScheduleAnyway                    |
|                                        |                                                                                                |    topologyKey: kubernetes.io/hostname                  |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|newRelic                                |*newRelic* bundles parametes required to configure *New Relic* monitoring system.               |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |- Requires IOM 5.0.0 or newer.                                                                  |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|newRelic.apm                            |*newRelic.apm* bundles parameters required to configure *New Relic APM* (Application Performance|                                                         |
|                                        |Monitoring).                                                                                    |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |- Requires IOM 5.0.0 or newer.                                                                  |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|newRelic.apm.enabled                    |If set to *true*, IOM will be started with ``-javagent`` parameter, loading the *New Relic APM* |false                                                    |
|                                        |javaagent library. This will not be the case when set to *false*.                               |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |- Requires IOM 5.0.0 or newer.                                                                  |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|newRelic.apm.licenseKey                 |A license-key is required to enable ingesting the data, see `New Relic Documentation about API  |                                                         |
|                                        |keys <https://docs.newrelic.com/docs/apis/intro-apis/new-relic-api-keys/#license-key>`_.        |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |- Ignored if *newRelic.apm.licenseKeySecretKeyRef* is set.                                      |                                                         |
|                                        |- Requires IOM 5.0.0 or newer.                                                                  |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|newRelic.apm.licenseKeySecretKeyRef     |Instead of storing the license key as plain text in the values file, a reference to a key within|                                                         |
|                                        |a secret can be used. For more information, see `References to entries of Kubernetes secrets    |                                                         |
|                                        |<SecretKeyRef.rst>`_                                                                            |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |- Required if *newRelic.apm.enabled* is set to *true* and *newRelic.apm.licenseKey* is not set. |                                                         |
|                                        |- Requires IOM 5.0.0 or newer.                                                                  |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|newRelic.apm.appName                    |Set name of application in *New Relic*. If left empty, a combination of chart-, release- and    |<chart name>-<helm release>-<namespace>                  |
|                                        |namespace-name will be used.                                                                    |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |- Requires IOM 5.0.0 or newer.                                                                  |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|newRelic.apm.backendOnly                |If set to *true* and *New Relic APM* is enabled, APM data will be captured only on the one IOM  |true                                                     |
|                                        |application server that is running the backend applications (singleton applications). If set to |                                                         |
|                                        |*false* and *New Relic APM* is enabled, APM data will be captured on all IOM application        |                                                         |
|                                        |servers.                                                                                        |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |- Requires IOM 5.0.0 or newer.                                                                  |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|newRelic.apm.config                     |Define further configuration values except for *app_name*, which is already defined by the      |.. code-block:: yaml                                     |
|                                        |parameter *newRelic.apm.appName*. For a full list of available settings, see `New Relic Docu    |                                                         |
|                                        |about Java agent config file template                                                           |  applicaction_logging:                                  |
|                                        |<https://docs.newrelic.com/docs/apm/agents/java-agent/configuration/                            |    enabled: false                                       |
|                                        |java-agent-config-file-template>`_.                                                             |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |Please note, that APM for logs is disabled by default values. Any change of                     |                                                         |
|                                        |*newRelic.apm.config* will overwrite the default values. E.g. to undo the configuration, that no|                                                         |
|                                        |logs are sent by APM (default behaviour), just define an empty *config* parameter.              |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |Examples:                                                                                       |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |.. code-block:: yaml                                                                            |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |  # Overwrite default settings of IOM Helm charts. This way the default settings of             |                                                         |
|                                        |  # New Relic APM will be used, which enable logs in APM (see link above).                      |                                                         |
|                                        |  newRelic:                                                                                     |                                                         |
|                                        |    apm:                                                                                        |                                                         |
|                                        |      config:                                                                                   |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |.. code-block:: yaml                                                                            |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |  # add more configuration settings, but disable logs.                                          |                                                         |
|                                        |  newRelic:                                                                                     |                                                         |
|                                        |    apm:                                                                                        |                                                         |
|                                        |      config:                                                                                   |                                                         |
|                                        |        application_logging:                                                                    |                                                         |
|                                        |          enabled: false                                                                        |                                                         |
|                                        |        send_data_on_exit: true                                                                 |                                                         |
|                                        |        max_stack_trace_lines: 20                                                               |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |- Requires IOM 5.0.0 or newer.                                                                  |                                                         |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|datadogApm                              |*datadogApm* bundles parameters required to configure datadog Application Performance Monitoring|                                                         |
|                                        |(APM).                                                                                          |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Deprecated since IOM Helm charts 3.0.0. Replaced by *newRelic*. Will be removed in a          |                                                         |
|                                        |  future version.                                                                               |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|datadogApm.enabled                      |This parameter is mapped to environment variable *DD_APM_ENABLED*. For more information, please |false                                                    |
|                                        |consult the official datadog documentation.  If set to *true*, IOM will be started with         |                                                         |
|                                        |``-javaagent`` parameter, loading the datadog javaagent library. This will not be the case when |                                                         |
|                                        |set to *false*.                                                                                 |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Deprecated since IOM Helm charts 3.0.0. Replaced by *newRelic*. Will be removed in a future   |                                                         |
|                                        |  version.                                                                                      |                                                         |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|datadogApm.backendOnly                  |If set to *true* and datadog APM is enabled, tracing will only be executed on the one IOM       |true                                                     |
|                                        |application server that is running the backend applications (singleton applications). If set to |                                                         |
|                                        |*true* and datadog APM is enabled, tracing will be executed on all IOM application servers.     |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Deprecated since IOM Helm charts 3.0.0. Replaced by *newRelic*. Will be removed in a future   |                                                         |
|                                        |  version.                                                                                      |                                                         |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|datadogApm.traceAgentHost               |This parameter is mapped to environment variable *DD_AGENT_HOST*. For more information, please  |                                                         |
|                                        |consult the official Datadog documentation.                                                     |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |Normally this environment variable is injected with the right value by the locally installed    |                                                         |
|                                        |datadog daemon-set.                                                                             |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Deprecated since IOM Helm charts 3.0.0. Replaced by *newRelic*. Will be removed in a future   |                                                         |
|                                        |  version.                                                                                      |                                                         |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|datadogApm.traceAgentPort               |This parameter is mapped to environment variable *DD_TRACE_AGENT_PORT*. For more information,   |                                                         |
|                                        |please consult the official Datadog documentation.                                              |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |Normally this environment variable is injected with the right value by the locally installed    |                                                         |
|                                        |datadog daemon-set.                                                                             |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Deprecated since IOM Helm charts 3.0.0. Replaced by *newRelic*. Will be removed in a future   |                                                         |
|                                        |  version.                                                                                      |                                                         |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|datadogApm.traceAgentTimeout            |This parameter is mapped to environment variable *DD_TRACE_AGENT_TIMEOUT*. For more information,|                                                         |
|                                        |please consult the official Datadog documentation.                                              |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Deprecated since IOM Helm charts 3.0.0. Replaced by *newRelic*. Will be removed in a future   |                                                         |
|                                        |  version.                                                                                      |                                                         |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|datadogApm.logsInjection                |This parameter is mapped to environment variable *DD_LOGS_INJECTION*. For more information,     |false                                                    |
|                                        |please consult the official Datadog documentation.                                              |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Deprecated since IOM Helm charts 3.0.0. Replaced by *newRelic*. Will be removed in a future   |                                                         |
|                                        |  version.                                                                                      |                                                         |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|datadogApm.debug                        |This parameter is mapped to environment variable *DD_TRACE_DEBUG*. For more information, please |false                                                    |
|                                        |consult the official Datadog documentation.                                                     |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Deprecated since IOM Helm charts 3.0.0. Replaced by *newRelic*. Will be removed in a future   |                                                         |
|                                        |  version.                                                                                      |                                                         |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|datadogApm.startupLogs                  |This parameter is mapped to environment variable *DD_TRACE_STARTUP_LOGS*. For more information, |true                                                     |
|                                        |please consult the official Datadog documentation.                                              |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Deprecated since IOM Helm charts 3.0.0. Replaced by *newRelic*. Will be removed in a future   |                                                         |
|                                        |  version.                                                                                      |                                                         |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|datadogApm.tags                         |This parameter is mapped to environment variable *DD_TAGS*. For more information, please consult|                                                         |
|                                        |the official Datadog documentation.                                                             |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Deprecated since IOM Helm charts 3.0.0. Replaced by *newRelic*. Will be removed in a future   |                                                         |
|                                        |  version.                                                                                      |                                                         |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|datadogApm.serviceMapping               |This parameter is mapped to environment variable *DD_SERVICE_MAPPING*. For more information,    |                                                         |
|                                        |please consult the official Datadog documentation.                                              |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Deprecated since IOM Helm charts 3.0.0. Replaced by *newRelic*. Will be removed in a future   |                                                         |
|                                        |  version.                                                                                      |                                                         |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|datadogApm.writerType                   |This parameter is mapped to environment variable *DD_WRITER_TYPE*. For more information, please |                                                         |
|                                        |consult the official Datadog documentation.                                                     |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Deprecated since IOM Helm charts 3.0.0. Replaced by *newRelic*. Will be removed in a future   |                                                         |
|                                        |  version.                                                                                      |                                                         |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|datadogApm.partialFlushMinSpan          |This parameter is mapped to environment variable *DD_TRACE_PARTIAL_FLUSH_MIN_SPANS*. For more   |                                                         |
|                                        |information, please consult the official Datadog documentation.                                 |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Deprecated since IOM Helm charts 3.0.0. Replaced by *newRelic*. Will be removed in a future   |                                                         |
|                                        |  version.                                                                                      |                                                         |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|datadogApm.dbClientSplitByInstance      |This parameter is mapped to environment variable *DD_TRACE_DB_CLIENT_SPLIT_BY_INSTANCE*. For    |                                                         |
|                                        |more information, please consult the official Datadog documentation.                            |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Deprecated since IOM Helm charts 3.0.0. Replaced by *newRelic*. Will be removed in a future   |                                                         |
|                                        |  version.                                                                                      |                                                         |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|datadogApm.healthMetricsEnabled         |This parameter is mapped to environment variable *DD_TRACE_HEALTH_METRICS_ENABLED*. For more    |false                                                    |
|                                        |information, please consult the official Datadog documentation.                                 |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Deprecated since IOM Helm charts 3.0.0. Replaced by *newRelic*. Will be removed in a future   |                                                         |
|                                        |  version.                                                                                      |                                                         |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|datadogApm.servletAsyncTimeoutError     |This parameter is mapped to environment variable *DD_TRACE_SERVLET_ASYNC_TIMEOUT_ERROR*. For    |true                                                     |
|                                        |more information, please consult the official Datadog documentation.                            |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Deprecated since IOM Helm charts 3.0.0. Replaced by *newRelic*. Will be removed in a future   |                                                         |
|                                        |  version.                                                                                      |                                                         |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|datadogApm.sampleRate                   |This parameter is mapped to environment variable *DD_TRACE_SAMPLE_RATE*. For more information,  |'1.0'                                                    |
|                                        |please consult the official Datadog documentation.                                              |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Deprecated since IOM Helm charts 3.0.0. Replaced by *newRelic*. Will be removed in a future   |                                                         |
|                                        |  version.                                                                                      |                                                         |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|datadogApm.jmsFetchEnabled              |This parameter is mapped to environment variable *DD_JMXFETCH_ENABLED*. For more information,   |true                                                     |
|                                        |please consult the official Datadog documentation.                                              |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Deprecated since IOM Helm charts 3.0.0. Replaced by *newRelic*. Will be removed in a future   |                                                         |
|                                        |  version.                                                                                      |                                                         |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|project                                 |Within project group of parameters, configuration of Intershop Commerce Platform (previously    |                                                         |
|                                        |known as CaaS) projects can be controlled.                                                      |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|project.envName                         |Intershop Commerce Platform (previously known as CaaS) projects support different settings for  |env-name                                                 |
|                                        |different environments. *project.envName* defines which one has to be used. See `Guide - IOM    |                                                         |
|                                        |Standard Project Structure                                                                      |                                                         |
|                                        |<https://github.com/intershop/iom-project-archetype/wiki/Directory-Structure-of-IOM-Projects>`__|                                                         |
|                                        |for more information.                                                                           |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|project.importTestData                  |Controls the import of test data, which are part of the project. See `Guide - IOM Standard      |false                                                    |
|                                        |Project Structure                                                                               |                                                         |
|                                        |<https://github.com/intershop/iom-project-archetype/wiki/Directory-Structure-of-IOM-Projects>`__|                                                         |
|                                        |for more information. If enabled, test data is imported during installation process but not on  |                                                         |
|                                        |upgrade.                                                                                        |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|project.importTestDataTimeout           |Timeout in seconds for the import of test data. If the import has not finished before the       |"300"                                                    |
|                                        |according amount of seconds has passed, the container will end with an error.                   |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|persistence                             |Parameters of group *persistence* control how IOM's shared data is persisted.                   |                                                         |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|persistence.storageClass                |Name of the existing storage class to be used for IOM's shared data.                            |azurefile                                                |
|                                        |                                                                                                |                                                         |
|                                        |* Ignored if *persistence.hostPath* is set.                                                     |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Ignored if *persistence.pvc* is set.                                                          |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|persistence.annotations                 |Annotations for persistence volume claim to be created. See                                     |"helm.sh/resource-policy": keep                          |
|                                        |https://helm.sh/docs/topics/charts_hooks/ for more information about default annotations.       |"helm.sh/hook": pre-install                              |
|                                        |                                                                                                |                                                         |
|                                        |* Ignored if *persistence.pvc* is set.                                                          |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|persistence.storageSize                 |Requested storage size. For more information, see the `official Kubernetes documentation on     |1Gi                                                      |
|                                        |storage <https://kubernetes.io/docs/concepts/storage/persistent-volumes/>`_.                    |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|persistence.hostPath                    |For very simple installations, persistent data can be stored directly at a local disk. In this  |                                                         |
|                                        |case, the path on local host has to be stored at this parameter.                                |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |* Ignored if *persistence.pvc* is set.                                                          |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|persistence.pvc                         |For transregional installations of IOM, it has to be possible to define the Persistence Volume  |                                                         |
|                                        |Claim (pvc) directly. This way IOM's shared data can be persisted at one place by two or more   |                                                         |
|                                        |IOM clusters.                                                                                   |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|ingress                                 |Group *ingress* bundles configuration of IOM's ingress, which is required to get access to IOM  |                                                         |
|                                        |from outside of Kubernetes.                                                                     |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|ingress.enabled                         |Enables ingress for IOM. If not enabled, IOM cannot be accessed from outside of Kubernetes.     |true                                                     |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|ingress.className                       |Ingress class has to be specified by *ingress.className*. This parameter controls on which      |nginx                                                    |
|                                        |ingress controller the ingress should be created.                                               |                                                         |
|                                        |                                                                                                |                                                         |
|                                        |If the integrated NGINX controller should be used to serve incoming requests, the parameter     |                                                         |
|                                        |*ingress.className* has to be set to *nginx-iom*.                                               |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|ingress.annotations                     |Annotations for the ingress.                                                                    |{}                                                       |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|ingress.hosts                           |A list of ingress hosts.                                                                        |.. code-block:: yaml                                     |
|                                        |                                                                                                |                                                         |
|                                        |The default value grants access to IOM. The syntax of ingress objects has to match the          |  - host: iom.example.local                              |
|                                        |requirements of Kubernetes 1.19                                                                 |    paths:                                               |
|                                        |(see https://kubernetes.io/docs/concepts/services-networking/ingress/).                         |      - path: /                                          |
|                                        |                                                                                                |        pathType: Prefix                                 |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|ingress.tls                             |A list of IngressTLS items.                                                                     |[]                                                       |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|resources                               |Resource requests & limits.                                                                     |.. code-block:: yaml                                     |
|                                        |                                                                                                |                                                         |
|                                        |                                                                                                |  resources:                                             |
|                                        |                                                                                                |    limits:                                              |
|                                        |                                                                                                |      cpu: 1000m                                         |
|                                        |                                                                                                |      memory: 2000Mi                                     |
|                                        |                                                                                                |    requests:                                            |
|                                        |                                                                                                |      cpu: 1000m                                         |
|                                        |                                                                                                |      memory: 2000Mi                                     |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|imagePullSecrets                        |List of the secrets to get credentials from.                                                    |[]                                                       |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|nameOverride                            |Overwrites the chart name.                                                                      |                                                         |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|fullnameOverride                        |Overwrites the complete name, constructed from release, and chart name.                         |                                                         |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|serviceAccount.create                   |If *true*, creates a backend service account. Only useful if you need a pod security policy to  |true                                                     |
|                                        |run the backend.                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|serviceAccount.annotations              |Annotations for the service account. Only used if *create* is *true*.                           |{}                                                       |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|serviceAccount.name                     |The name of the backend service account to use. If not set and *create* is *true*, a name is    |                                                         |
|                                        |generated using the fullname template. Only useful if you need a pod security policy to run the |                                                         |
|                                        |backend.                                                                                        |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|podAnnotations                          |Annotations to be added to pods.                                                                |{}                                                       |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|podSecurityContext                      |Security context policies to add to the iom-tests pod.                                          |{}                                                       |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|securityContext                         |List of required privileges.                                                                    |{}                                                       |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|service.type                            |Type of service to create.                                                                      |ClusterIP                                                |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|service.port                            |Port to be exposed by service.                                                                  |80                                                       |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|nodeSelector                            |Node labels for pod assignment.                                                                 |{}                                                       |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+
|tolerations                             |Node taints to tolerate.                                                                        |[]                                                       |
|                                        |                                                                                                |                                                         |
+----------------------------------------+------------------------------------------------------------------------------------------------+---------------------------------------------------------+

+-------------------+-----------------+-------------------------+
|`< Back            |`^ Up            |`Next >                  |
|<ExampleProd.rst>`_|<../README.rst>`_|<ParametersMailhog.rst>`_|
+-------------------+-----------------+-------------------------+
