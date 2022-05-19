+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|Parameter                               |Description                                                                                   |Default Value                                 |
|                                        |                                                                                              |                                              |
+========================================+==============================================================================================+==============================================+
|replicaCount                            |The number of IOM application server instances to run in parallel.                            |2                                             |
|                                        |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|downtime                                |The *downtime* parameter is a very critical one. Its goal and behavior is                     |true                                          |
|                                        |already described in `Restrictions on Upgrade <TODO>`_.                                       |                                              |
|                                        |                                                                                              |                                              |
|                                        |Additional information:                                                                       |                                              |
|                                        |                                                                                              |                                              |
|                                        |* If *downtime* is set to *false*, the DBmigrate process, as part of the process              |                                              |
|                                        |  the config init-container is executing, is skipped. This has no impact on the               |                                              |
|                                        |  project configuration.                                                                      |                                              |
|                                        |                                                                                              |                                              |
|                                        |* For the *downtime* parameter to work correctly, the ``--wait`` and                          |                                              |
|                                        |  ``--timeout`` command line parameters must always be set when running Helm.                 |                                              |
|                                        |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|image.repository                        |Repository of the IOM app product/project image.                                              |docker.intershop.de/intershophub/iom          |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|image.pullPolicy                        |Pull policy, to be applied when getting IOM product/project Docker image. For                 |IfNotPresent                                  |
|                                        |more information, see the `official Kubernetes documentation                                  |                                              |
|                                        |<https://kubernetes.io/docs/concepts/containers/images/#image-pull-policy>`_.                 |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|image.tag                               |The tag of IOM product/project image.                                                         |4.0.0                                         |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|dbaccount                               |Parameters bundled by dbaccount are used to control the dbaccount init-container              |                                              |
|                                        |which creates the IOM database-user and the IOM database itself. To enable the                |                                              |
|                                        |dbaccount init-container to do this, it needs to get superuser access to the                  |                                              |
|                                        |PostgreSQL server and it requires the according information about the IOM                     |                                              |
|                                        |database. This information is not contained in dbaccount parameters. Instead,                 |                                              |
|                                        |the general connection and superuser information are retrieved from *pg* or                   |                                              |
|                                        |*postgres.pg* parameters (depending on *postgres.enabled*). All information                   |                                              |
|                                        |about the IOM database user and database are provided by *oms.db* parameters.                 |                                              |
|                                        |                                                                                              |                                              |
|                                        |Once the IOM database is created, the dbaccount init-container is not needed any              |                                              |
|                                        |longer. Hence, all IOM installations, except really non-critical demo- and                    |                                              |
|                                        |CI-setups, should enable dbaccount init-container only temporarily to initialize              |                                              |
|                                        |the database account.                                                                         |                                              |
|                                        |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|dbaccount.enabled                       |Controls if the dbaccount init-container should be executed or not. If enabled,               |false                                         |
|                                        |dbaccount will only be executed when installing IOM, not on upgrade operations.               |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|dbaccount.image.repository              |Repository of the dbaccount image.                                                            |docker.intershop.de/intershophub/iom-dbaccount|
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|dbaccount.image.pullPolicy              |Pull policy, to be applied when getting dbaccount Docker image. For more                      |IfNotPresent                                  |
|                                        |information, see the `official Kubernetes documentation                                       |                                              |
|                                        |<https://kubernetes.io/docs/concepts/containers/images/#image-pull-policy>`_.                 |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|dbaccount.image.tag                     |The tag of dbaccount image.                                                                   |1.4.0                                         |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|dbaccount.resetData                     |Controls if dbaccount init-container should reset an already existing IOM                     |false                                         |
|                                        |database during the installation process of IOM. If set to *true*, existing data              |                                              |
|                                        |is deleted without backup and further warning.                                                |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|dbaccount.options                       |When creating the IOM database, more options added to OWNER are                               |"ENCODING='UTF8' LC_COLLATE='en_US.utf8'      |
|                                        |required. Depending on the configuration of the PostgreSQL server, these options              |LC_CTYPE='en_US.utf8' CONNECTION LIMIT=-1     |
|                                        |may differ. The default values can be used as they are for integrated PostgreSQL              |TEMPLATE=template0"                           |
|                                        |server, for Azure Database for PostgreSQL service, and for most other servers,                |                                              |
|                                        |too.                                                                                          |                                              |
|                                        |                                                                                              |                                              |
|                                        |See `Options and Requirements of IOM database <TODO>`_ for details.                           |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|dbaccount.searchPath                    |In some circumstances, the search path for database objects has to be                         |                                              |
|                                        |extended. This is the case if custom schemas are used for customizations or                   |                                              |
|                                        |tests. To add more schemas to the search-path, set the current parameter to a                 |                                              |
|                                        |string containing all additional schemas, separated by a comma, e.g. "tests,                  |                                              |
|                                        |customschema". The additional entries are inserted at the beginning of the                    |                                              |
|                                        |search-path, hence objects with the same name as standard objects of IOM are                  |                                              |
|                                        |found first.                                                                                  |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|dbaccount.tablespace                    |Use the passed tablespace as default for IOM database user and IOM                            |                                              |
|                                        |database. Tablespace has to exist, it will not be created.                                    |                                              |
|                                        |                                                                                              |                                              |
|                                        |Section `Options and Requirements of IOM database <TODO>`_ will give you some                 |                                              |
|                                        |more information.                                                                             |                                              |
|                                        |                                                                                              |                                              |
|                                        |* Ignored if *postgres.enabled* is *true*, since the integrated PostgreSQL                    |                                              |
|                                        |  server can never create a custom tablespace prior to the initialization of the              |                                              |
|                                        |  IOM database user and IOM database.                                                         |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|dbaccount.resources                     |Resource requests & limits.                                                                   |{}                                            |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|config                                  |Parameters, bundled by *config*, are used to control the config init-container                |                                              |
|                                        |which fills the IOM database, to apply database migrations, and to roll out                   |                                              |
|                                        |project configurations into the IOM database. To enable the config                            |                                              |
|                                        |init-container to do this, it requires access to the IOM database. This                       |                                              |
|                                        |information is not contained in config parameters. Instead, the general                       |                                              |
|                                        |connection information is retrieved from *pg* or *postgres.pg* parameters. All                |                                              |
|                                        |information about the IOM database user and database are provided by *oms.db*                 |                                              |
|                                        |parameters.                                                                                   |                                              |
|                                        |                                                                                              |                                              |
|                                        |The config init-container was removed along with IOM 4.0.0. The according                     |                                              |
|                                        |functionality is now executed by the IOM container itself. The *config*                       |                                              |
|                                        |parameter still exists for backward compatibility.                                            |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|config.enabled                          |The config init-container was removed along with IOM 4.0.0. For backward                      |false                                         |
|                                        |compatibility it can still be used, but has to be enabled explicitly now.                     |                                              |
|                                        |                                                                                              |                                              |
|                                        |* Has to be set to *true*, when using Helm charts with an IOM version < 4.0.0.                |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|config.image.repository                 |Repository of the IOM config product/project image.                                           |docker.intershop.de/intershophub/iom-config   |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|config.image.pullPolicy                 |Pull policy, to be applied when getting the IOM config product/project Docker                 |IfNotPresent                                  |
|                                        |image. For more information, see the `official Kubernetes documentation                       |                                              |
|                                        |<https://kubernetes.io/docs/concepts/containers/images/#image-pull-policy>`_.                 |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|config.image.tag                        |The tag of IOM config product/project image.                                                  |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|config.resources                        |Resource requests & limits.                                                                   |{}                                            |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|oms.skipProcedures                      |Normally, when updating the config image of IOM, stored procedures, migration                 |false                                         |
|                                        |scripts, and project configuration are executed. Setting parameter                            |                                              |
|                                        |*oms.skipProcedures* to *true* allows to skip the execution of stored                         |                                              |
|                                        |procedures. You must not do this when updating IOM.                                           |                                              |
|                                        |                                                                                              |                                              |
|                                        |* Requires IOM >= 3.6.0.0 and < 4.0.0                                                         |                                              |
|                                        |                                                                                              |                                              |
|                                        |* In IOM 4.0.0 and newer, execution of                                                        |                                              |
|                                        |  procedures, migration, and configuration is tracked internally and will not be              |                                              |
|                                        |  executed if already applied. A manual control is not necessary any longer.                  |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|oms.skipMigration                       |Normally, when updating the config image of IOM, stored procedures, migration                 |false                                         |
|                                        |scripts, and project configuration are executed. Setting parameter                            |                                              |
|                                        |*oms.skipMigration* to *true* allows to skip the execution of migration                       |                                              |
|                                        |scripts. You must not do this when updating IOM.                                              |                                              |
|                                        |                                                                                              |                                              |
|                                        |* Requires IOM >= 3.6.0.0 and < 4.0.0                                                         |                                              |
|                                        |                                                                                              |                                              |
|                                        |* In IOM 4.0.0 and newer, execution of procedures, migration, and configuration               |                                              |
|                                        |  is tracked internally and will not be executed if already applied. A manual                 |                                              |
|                                        |  control is not necessary any longer.                                                        |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|oms.skipConfig                          |Normally, when updating the config image of IOM, stored procedures, migration                 |false                                         |
|                                        |scripts, and project configuration are executed. Setting parameter                            |                                              |
|                                        |*oms.skipConfig* to *true* allows to skip the execution of configuration                      |                                              |
|                                        |scripts. You must not do this when updating the project configuration.                        |                                              |
|                                        |                                                                                              |                                              |
|                                        |* Requires IOM >= 3.6.0.0 and < 4.0.0                                                         |                                              |
|                                        |                                                                                              |                                              |
|                                        |* In IOM 4.0.0 and newer, execution of procedures, migration, and configuration               |                                              |
|                                        |  is tracked internally and will not be executed if already applied. A manual                 |                                              |
|                                        |  control is not necessary any longer.                                                        |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|pg                                      |This group of parameters bundles the information required to connect the                      |                                              |
|                                        |PostgreSQL server, information about the superuser, and default database                      |                                              |
|                                        |(management database, not the IOM database).                                                  |                                              |
|                                        |                                                                                              |                                              |
|                                        |Not all clients need all information:                                                         |                                              |
|                                        |                                                                                              |                                              |
|                                        |The dbaccount init-container is the only client that needs access to the                      |                                              |
|                                        |PostgreSQL server as a superuser. Hence, if you do not enable dbaccount, the                  |                                              |
|                                        |parameters *pg.user(SecretKeyRef)*, *pg.passwd(SecretKeyRef)* and *pg.db* should              |                                              |
|                                        |not be set at all.                                                                            |                                              |
|                                        |                                                                                              |                                              |
|                                        |If integrated PostgreSQL server is enabled (*postgres.enabled* set to *true*),                |                                              |
|                                        |all parameters defined by *pg* are ignored completely. In this case, parameters               |                                              |
|                                        |defined by *postgres.pg* are used instead.                                                    |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|pg.user                                 |Name of the superuser.                                                                        |postgres                                      |
|                                        |                                                                                              |                                              |
|                                        |* Required only if *dbaccount.enabled* is set to *true*.                                      |                                              |
|                                        |                                                                                              |                                              |
|                                        |* Ignored if *postgres.enabled* is set to *true*.                                             |                                              |
|                                        |                                                                                              |                                              |
|                                        |* Ignored if *pg.userSecretKeyRef* is set.                                                    |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|pg.userSecretKeyRef                     |Instead of storing the name of the user as plain text in the values file, a                   |                                              |
|                                        |reference to a key within a secret can be used. For more information see section              |                                              |
|                                        |`References to entries of Kubernetes secrets <TODO>`_.                                        |                                              |
|                                        |                                                                                              |                                              |
|                                        |* Required only if *dbaccount.enabled* is set to *true* and *pg.user* is not                  |                                              |
|                                        |set.                                                                                          |                                              |
|                                        |                                                                                              |                                              |
|                                        |* Ignored if *postgres.enabled* is set to *true*.                                             |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|pg.passwd                               |The password of the superuser.                                                                |postgres                                      |
|                                        |                                                                                              |                                              |
|                                        |* Required only if *dbaccount.enabled* is set to *true*.                                      |                                              |
|                                        |                                                                                              |                                              |
|                                        |* Ignored if *postgres.enabled* is set to *true*.                                             |                                              |
|                                        |                                                                                              |                                              |
|                                        |* Ignored if *pg.passwdSecretKeyRef* is set.                                                  |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|pg.passwdSecretKeyRef                   |Instead of storing the password as plain text in the values file, a reference to              |                                              |
|                                        |a key within a secret can be used. For more information see section `References               |                                              |
|                                        |to entries of Kubernetes secrets <TODO>`_.                                                    |                                              |
|                                        |                                                                                              |                                              |
|                                        |* Required only if *dbaccount.enabled* is set to *true* and *pg.passwd* is not                |                                              |
|                                        |set.                                                                                          |                                              |
|                                        |                                                                                              |                                              |
|                                        |* Ignored if *postgres.enabled* is set to *true*.                                             |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|pg.db                                   |Name of the default (management) database.                                                    |postgres                                      |
|                                        |                                                                                              |                                              |
|                                        |* Required only if *dbaccount.enabled* is set to *true*.                                      |                                              |
|                                        |                                                                                              |                                              |
|                                        |* Ignored if *postgres.enabled* is set to *true*.                                             |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|pg.host                                 |The hostname of the PostgreSQL server.                                                        |postgres-service                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|pg.port                                 |Port of the PostgreSQL server.                                                                |"5432"                                        |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|pg.userConnectionSuffix                 |When using the Azure Database for PostgreSQL service, user names have to be extended by a     |                                              |
|                                        |suffix, beginning with '@'. For more information, refer to the `official Azure Database for   |                                              |
|                                        |PostgreSQL documentation                                                                      |                                              |
|                                        |<https://docs.microsoft.com/en-us/azure/postgresql/connect-java#get-connection-information>`_.|                                              |
|                                        |                                                                                              |                                              |
|                                        |This suffix is not a part of the user name. It has to be used only when connecting to the     |                                              |
|                                        |database. For this reason, the parameter *pg.userConnectionSuffix* was separated from         |                                              |
|                                        |*pg.user* and *oms.db.user*.                                                                  |                                              |
|                                        |                                                                                              |                                              |
|                                        |Example: "@mydemoserver"                                                                      |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|pg.sslMode                              |*pg.sslMode* has to contain one of the following values: *disable*, *allow*, *prefer*,        |prefer                                        |
|                                        |*require*, *verify-ca*, *verify-full*. For a detailed description of settings, please see `the|                                              |
|                                        |official PostgreSQL documentation                                                             |                                              |
|                                        |<https://www.postgresql.org/docs/12/libpq-connect.html#LIBPQ-CONNSTRING>`_.                   |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|pg.sslCompression                       |If set to "1", data sent over SSL connections will be compressed. If set to "0", compression  |"0"                                           |
|                                        |will be disabled. For a detailed description, please see the `official PostgreSQL             |                                              |
|                                        |documentation <https://www.postgresql.org/docs/12/libpq-connect.html#LIBPQ-CONNSTRING>`_.     |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|pg.sslRootCert                          |Azure Database for PostgreSQL service might require verification of the server certificate,   |                                              |
|                                        |see the `official Azure Database for PostgreSQL documentation <TODO>`_. To handle this case,  |                                              |
|                                        |it is possible to pass the SSL root certificate in pg.sslRootCert.                            |                                              |
|                                        |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|oms                                     |Parameters of group *oms* are all related to the configuration of IOM.                        |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|oms.publicUrl                           |The publicly accessible base URL of IOM which could be the DNS name of the load balancer,     |https://localhost                             |
|                                        |etc. It is used internally for link generation.                                               |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|oms.mailResourcesBaseUrl                |The base path for e-mail resources that are loaded from the e-mail client, e.g., images or    |https://localhost/mailimages/customers        |
|                                        |stylesheets. Also, see `Concept - IOM Customer Emails <TODO>`_.                               |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|oms.jwtSecret                           |The shared secret for `JSON Web Token <https://jwt.io/>`_ (JWT) creation/validation. JWTs will|length_must_be_at_least_32_chars              |
|                                        |be generated with the HMAC algorithm (HS256).                                                 |                                              |
|                                        |                                                                                              |                                              |
|                                        |Intershop strongly recommends to change the default shared secret used for the `JSON Web      |                                              |
|                                        |Tokens <https://jwt.io/>`_ creation/validation.                                               |                                              |
|                                        |                                                                                              |                                              |
|                                        |To secure the JWT, a key of the same size as the hash output or larger must be used with the  |                                              |
|                                        |JWS HMAC SHA-2 algorithms (i.e, 256 bits for "HS256"), see `JSON Web Algorithms (JWA) |       |                                              |
|                                        |3.2. HMAC with SHA-2 Functions <https://tools.ietf.org/html/rfc7518#section-3.2>`_.           |                                              |
|                                        |                                                                                              |                                              |
|                                        |* Ignored if *oms.jwtSecretKeyRef* is set.                                                    |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|oms.jwtSecretKeyRef                     |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|oms.archiveOrderMessageLogMinAge        |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|oms.deleteOrderMessageLogMinAge         |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|oms.archiveShopCustomerMailMinAge       |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|oms.archiveShopCustomerMailMaxCount     |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|oms.deleteShopCustomerMailMinAge        |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|oms.secureCookiesEnabled                |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|oms.execBackendApps                     |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|oms.db                                  |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|oms.db.name                             |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|oms.db.user                             |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|oms.db.userSecretKeyRef                 |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|oms.db.passwd                           |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|oms.db.passwdSecretKeyRef               |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|oms.db.hostlist                         |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|oms.db.connectionMonitor                |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|oms.db.connectionMonitor.enabled        |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|oms.db.connectionMonitor.schedule       |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|oms.db.connectTimeout                   |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|oms.smtp                                |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|oms.smtp.host                           |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|oms.smtp.port                           |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|oms.smtp.user                           |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|oms.smtp.userSecretKeyRef               |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|oms.smtp.passwd                         |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|oms.smtp.passwdSecretKeyRef             |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|startupProbe                            |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|startupProbe.enabled                    |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|startupProbe.periodSeconds              |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|startupProbe.initialDelaySeconds        |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|startupProbe.timeoutSeconds             |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|startupProbe.failureThreshold           |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|livenessProbe                           |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|livenessProbe.enabled                   |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|livenessProbe.periodSeconds             |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|livenessProbe.initialDelaySeconds       |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|livenessProbe.timeoutSeconds            |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|livenessProbe.failureThreshold          |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|readinessProbe                          |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|readinessProbe.enabled                  |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|readinessProbe.periodSeconds            |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|readinessProbe.initialDelaySeconds      |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|readinessProbe.timeoutSeconds           |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|readinessProbe.failureThreshold         |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|readinessProbe.successThreshold         |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|jboss                                   |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|jboss.javaOpts                          |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|jboss.javaOptsAppend                    |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|jboss.opts                              |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|jboss.xaPoolsizeMin                     |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|jboss.xaPoolsizeMax                     |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|jboss.activemqClientPoolSizeMax         |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|jboss.nodePrefix                        |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|log                                     |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|log.access.enabled                      |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|log.level.scripts                       |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|log.level.iom                           |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|log.level.hibernate                     |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|log.level.quartz                        |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|log.level.activeMQ                      |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|log.level.console                       |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|log.level.customization                 |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|log.metadata                            |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|log.metadata.tenant                     |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|log.metadata.environment                |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|log.rest                                |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|datadogApm                              |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|datadogApm.enabled                      |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|datadogApm.backendOnly                  |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|datadogApm.traceAgentHost               |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|datadogApm.traceAgentPort               |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|datadogApm.traceAgentTimeout            |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|datadogApm.logsInjection                |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|datadogApm.debug                        |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|datadogApm.startupLogs                  |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|datadogApm.tags                         |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|datadogApm.serviceMapping               |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|datadogApm.writerType                   |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|datadogApm.partialFlushMinSpan          |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|datadogApm.dbClientSplitByInstance      |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|datadogApm.healthMetricsEnabled         |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|datadogApm.servletAsyncTimeoutError     |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|datadogApm.sampleRate                   |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|datadogApm.jmsFetchEnabled              |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|project                                 |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|project.envName                         |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|project.importTestData                  |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|project.importTestDataTimeout           |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|persistence                             |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|persistence.storageClass                |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|persistence.annotations                 |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|persistence.storageSize                 |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|persistence.hostPath                    |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|persistence.pvc                         |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|ingress                                 |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|ingress.enabled                         |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|ingress.className                       |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|ingress.annotations                     |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|ingress.hosts                           |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|ingress.tls                             |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|resources                               |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|imagePullSecrets                        |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|nameOverride                            |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|fullnameOverride                        |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|serviceAccount.create                   |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|serviceAccount.annotations              |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|serviceAccount.name                     |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|podAnnotations                          |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|podSecurityContext                      |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|securityContext                         |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|service.type                            |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|service.port                            |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|nodeSelector                            |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|tolerations                             |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
|affinity                                |                                                                                              |                                              |
|                                        |                                                                                              |                                              |
+----------------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------+
