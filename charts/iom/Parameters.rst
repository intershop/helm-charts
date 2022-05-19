+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|Parameter                               |Description                                                                     |Default Value                                 |
|                                        |                                                                                |                                              |
+========================================+================================================================================+==============================================+
|replicaCount                            |The number of IOM application server instances to run in parallel.              |2                                             |
|                                        |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|downtime                                |The *downtime* parameter is a very critical one. Its goal and behavior is       |true                                          |
|                                        |already described in `Restrictions on Upgrade <TODO>`_.                         |                                              |
|                                        |                                                                                |                                              |
|                                        |Additional information:                                                         |                                              |
|                                        |                                                                                |                                              |
|                                        |* If *downtime* is set to *false*, the DBmigrate process, as part of the process|                                              |
|                                        |  the config init-container is executing, is skipped. This has no impact on the |                                              |
|                                        |  project configuration.                                                        |                                              |
|                                        |                                                                                |                                              |
|                                        |* For the *downtime* parameter to work correctly, the ``--wait`` and            |                                              |
|                                        |  ``--timeout`` command line parameters must always be set when running Helm.   |                                              |
|                                        |                                                                                |                                              |
|                                        |                                                                                |                                              |
|                                        |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|image.repository                        |Repository of the IOM app product/project image.                                |docker.intershop.de/intershophub/iom          |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|image.pullPolicy                        |Pull policy, to be applied when getting IOM product/project Docker image. For   |IfNotPresent                                  |
|                                        |more information, see the `official Kubernetes documentation                    |                                              |
|                                        |<https://kubernetes.io/docs/concepts/containers/images/#image-pull-policy>`_.   |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|image.tag                               |The tag of IOM product/project image.                                           |4.0.0                                         |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|dbaccount                               |Parameters bundled by dbaccount are used to control the dbaccount init-container|                                              |
|                                        |which creates the IOM database-user and the IOM database itself. To enable the  |                                              |
|                                        |dbaccount init-container to do this, it needs to get superuser access to the    |                                              |
|                                        |PostgreSQL server and it requires the according information about the IOM       |                                              |
|                                        |database. This information is not contained in dbaccount parameters. Instead,   |                                              |
|                                        |the general connection and superuser information are retrieved from *pg* or     |                                              |
|                                        |*postgres.pg* parameters (depending on *postgres.enabled*). All information     |                                              |
|                                        |about the IOM database user and database are provided by *oms.db* parameters.   |                                              |
|                                        |                                                                                |                                              |
|                                        |Once the IOM database is created, the dbaccount init-container is not needed any|                                              |
|                                        |longer. Hence, all IOM installations, except really non-critical demo- and      |                                              |
|                                        |CI-setups, should enable dbaccount init-container only temporarily to initialize|                                              |
|                                        |the database account.                                                           |                                              |
|                                        |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|dbaccount.enabled                       |Controls if the dbaccount init-container should be executed or not. If enabled, |false                                         |
|                                        |dbaccount will only be executed when installing IOM, not on upgrade operations. |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|dbaccount.image.repository              |Repository of the dbaccount image.                                              |docker.intershop.de/intershophub/iom-dbaccount|
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|dbaccount.image.pullPolicy              |Pull policy, to be applied when getting dbaccount Docker image. For more        |IfNotPresent                                  |
|                                        |information, see the `official Kubernetes documentation                         |                                              |
|                                        |<https://kubernetes.io/docs/concepts/containers/images/#image-pull-policy>`_.   |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|dbaccount.image.tag                     |The tag of dbaccount image.                                                     |1.4.0                                         |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|dbaccount.resetData                     |Controls if dbaccount init-container should reset an already existing IOM       |false                                         |
|                                        |database during the installation process of IOM. If set to *true*, existing data|                                              |
|                                        |is deleted without backup and further warning.                                  |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|dbaccount.options                       |When creating the IOM database, more options added to OWNER are                 |"ENCODING='UTF8' LC_COLLATE='en_US.utf8'      |
|                                        |required. Depending on the configuration of the PostgreSQL server, these options|LC_CTYPE='en_US.utf8' CONNECTION LIMIT=-1     |
|                                        |may differ. The default values can be used as they are for integrated PostgreSQL|TEMPLATE=template0"                           |
|                                        |server, for Azure Database for PostgreSQL service, and for most other servers,  |                                              |
|                                        |too.                                                                            |                                              |
|                                        |                                                                                |                                              |
|                                        |See `Options and Requirements of IOM database <TODO>`_ for details.             |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|dbaccount.searchPath                    |In some circumstances, the search path for database objects has to be           |                                              |
|                                        |extended. This is the case if custom schemas are used for customizations or     |                                              |
|                                        |tests. To add more schemas to the search-path, set the current parameter to a   |                                              |
|                                        |string containing all additional schemas, separated by a comma, e.g. "tests,    |                                              |
|                                        |customschema". The additional entries are inserted at the beginning of the      |                                              |
|                                        |search-path, hence objects with the same name as standard objects of IOM are    |                                              |
|                                        |found first.                                                                    |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|dbaccount.tablespace                    |Use the passed tablespace as default for IOM database user and IOM              |                                              |
|                                        |database. Tablespace has to exist, it will not be created.                      |                                              |
|                                        |                                                                                |                                              |
|                                        |Section `Options and Requirements of IOM database <TODO>`_ will give you some   |                                              |
|                                        |more information.                                                               |                                              |
|                                        |                                                                                |                                              |
|                                        |* Ignored if *postgres.enabled* is *true*, since the integrated PostgreSQL      |                                              |
|                                        |  server can never create a custom tablespace prior to the initialization of the|                                              |
|                                        |  IOM database user and IOM database.                                           |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|dbaccount.resources                     |Resource requests & limits.                                                     |{}                                            |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|config                                  |Parameters, bundled by *config*, are used to control the config init-container  |                                              |
|                                        |which fills the IOM database, to apply database migrations, and to roll out     |                                              |
|                                        |project configurations into the IOM database. To enable the config              |                                              |
|                                        |init-container to do this, it requires access to the IOM database. This         |                                              |
|                                        |information is not contained in config parameters. Instead, the general         |                                              |
|                                        |connection information is retrieved from *pg* or *postgres.pg* parameters. All  |                                              |
|                                        |information about the IOM database user and database are provided by *oms.db*   |                                              |
|                                        |parameters.                                                                     |                                              |
|                                        |                                                                                |                                              |
|                                        |The config init-container was removed along with IOM 4.0.0. The according       |                                              |
|                                        |functionality is now executed by the IOM container itself. The *config*         |                                              |
|                                        |parameter still exists for backward compatibility.                              |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|config.enabled                          |The config init-container was removed along with IOM 4.0.0. For backward        |false                                         |
|                                        |compatibility it can still be used, but has to be enabled explicitly now.       |                                              |
|                                        |                                                                                |                                              |
|                                        |* Has to be set to *true*, when using Helm charts with an IOM version < 4.0.0.  |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|config.image.repository                 |Repository of the IOM config product/project image.                             |docker.intershop.de/intershophub/iom-config   |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|config.image.pullPolicy                 |Pull policy, to be applied when getting the IOM config product/project Docker   |IfNotPresent                                  |
|                                        |image. For more information, see the `official Kubernetes documentation         |                                              |
|                                        |<https://kubernetes.io/docs/concepts/containers/images/#image-pull-policy>`_.   |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|config.image.tag                        |The tag of IOM config product/project image.                                    |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|config.resources                        |Resource requests & limits.                                                     |{}                                            |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|oms.skipProcedures                      |Normally, when updating the config image of IOM, stored procedures, migration   |false                                         |
|                                        |scripts, and project configuration are executed. Setting parameter              |                                              |
|                                        |*oms.skipProcedures* to *true* allows to skip the execution of stored           |                                              |
|                                        |procedures. You must not do this when updating IOM.                             |                                              |
|                                        |                                                                                |                                              |
|                                        |* Requires IOM >= 3.6.0.0 and < 4.0.0                                           |                                              |
|                                        |                                                                                |                                              |
|                                        |* In IOM 4.0.0 and newer, execution of                                          |                                              |
|                                        |  procedures, migration, and configuration is tracked internally and will not be|                                              |
|                                        |  executed if already applied. A manual control is not necessary any longer.    |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|oms.skipMigration                       |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|oms.skipConfig                          |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|.. _hyperlink-name: pg                  |                                                                                |                                              |
|                                        |                                                                                |                                              |
|pg                                      |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|pg.user                                 |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|pg.userSecretKeyRef                     |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|pg.passwd                               |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|pg.passwdSecretKeyRef                   |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|pg.db                                   |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|pg.host                                 |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|pg.port                                 |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|pg.userConnectionSuffix                 |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|pg.sslMode                              |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|pg.sslCompression                       |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|pg.sslRootCert                          |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|oms                                     |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|oms.publicUrl                           |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|oms.mailResourcesBaseUrl                |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|oms.jwtSecret                           |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|oms.jwtSecretKeyRef                     |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|oms.archiveOrderMessageLogMinAge        |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|oms.deleteOrderMessageLogMinAge         |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|oms.archiveShopCustomerMailMinAge       |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|oms.archiveShopCustomerMailMaxCount     |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|oms.deleteShopCustomerMailMinAge        |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|oms.secureCookiesEnabled                |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|oms.execBackendApps                     |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|oms.db                                  |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|oms.db.name                             |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|oms.db.user                             |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|oms.db.userSecretKeyRef                 |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|oms.db.passwd                           |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|oms.db.passwdSecretKeyRef               |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|oms.db.hostlist                         |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|oms.db.connectionMonitor                |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|oms.db.connectionMonitor.enabled        |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|oms.db.connectionMonitor.schedule       |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|oms.db.connectTimeout                   |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|oms.smtp                                |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|oms.smtp.host                           |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|oms.smtp.port                           |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|oms.smtp.user                           |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|oms.smtp.userSecretKeyRef               |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|oms.smtp.passwd                         |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|oms.smtp.passwdSecretKeyRef             |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|startupProbe                            |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|startupProbe.enabled                    |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|startupProbe.periodSeconds              |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|startupProbe.initialDelaySeconds        |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|startupProbe.timeoutSeconds             |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|startupProbe.failureThreshold           |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|livenessProbe                           |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|livenessProbe.enabled                   |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|livenessProbe.periodSeconds             |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|livenessProbe.initialDelaySeconds       |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|livenessProbe.timeoutSeconds            |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|livenessProbe.failureThreshold          |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|readinessProbe                          |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|readinessProbe.enabled                  |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|readinessProbe.periodSeconds            |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|readinessProbe.initialDelaySeconds      |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|readinessProbe.timeoutSeconds           |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|readinessProbe.failureThreshold         |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|readinessProbe.successThreshold         |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|jboss                                   |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|jboss.javaOpts                          |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|jboss.javaOptsAppend                    |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|jboss.opts                              |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|jboss.xaPoolsizeMin                     |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|jboss.xaPoolsizeMax                     |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|jboss.activemqClientPoolSizeMax         |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|jboss.nodePrefix                        |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|log                                     |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|log.access.enabled                      |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|log.level.scripts                       |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|log.level.iom                           |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|log.level.hibernate                     |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|log.level.quartz                        |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|log.level.activeMQ                      |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|log.level.console                       |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|log.level.customization                 |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|log.metadata                            |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|log.metadata.tenant                     |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|log.metadata.environment                |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|log.rest                                |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|datadogApm                              |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|datadogApm.enabled                      |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|datadogApm.backendOnly                  |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|datadogApm.traceAgentHost               |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|datadogApm.traceAgentPort               |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|datadogApm.traceAgentTimeout            |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|datadogApm.logsInjection                |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|datadogApm.debug                        |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|datadogApm.startupLogs                  |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|datadogApm.tags                         |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|datadogApm.serviceMapping               |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|datadogApm.writerType                   |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|datadogApm.partialFlushMinSpan          |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|datadogApm.dbClientSplitByInstance      |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|datadogApm.healthMetricsEnabled         |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|datadogApm.servletAsyncTimeoutError     |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|datadogApm.sampleRate                   |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|datadogApm.jmsFetchEnabled              |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|project                                 |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|project.envName                         |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|project.importTestData                  |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|project.importTestDataTimeout           |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|persistence                             |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|persistence.storageClass                |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|persistence.annotations                 |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|persistence.storageSize                 |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|persistence.hostPath                    |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|persistence.pvc                         |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|ingress                                 |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|ingress.enabled                         |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|ingress.className                       |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|ingress.annotations                     |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|ingress.hosts                           |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|ingress.tls                             |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|resources                               |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|imagePullSecrets                        |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|nameOverride                            |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|fullnameOverride                        |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|serviceAccount.create                   |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|serviceAccount.annotations              |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|serviceAccount.name                     |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|podAnnotations                          |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|podSecurityContext                      |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|securityContext                         |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|service.type                            |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|service.port                            |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|nodeSelector                            |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|tolerations                             |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
|affinity                                |                                                                                |                                              |
|                                        |                                                                                |                                              |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------------+
