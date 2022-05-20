.. topic:: Navigation

  `< Back <SecretKeyRef.rst>`_ | `^ Up <../README.rst>`_ | `Next > <IOMDatabase.rst>`_

PostgreSQL Server Configuration
*******************************

.. note::

  The ideal configuration mainly depends on the server resources and on the activity. Therefore, we can only provide a general guideline. The configuration ranges indicated below may not be applicable in all cases, especially on small systems. These values are intended for a mid-size system with about 32 GB RAM and 24 cores.

  If *PostgreSQL* is used as a service (e.g. Azure Database for *PostgreSQL* servers), not all *PostgreSQL* server parameters can be set. When using a service, the method of how to change *PostgreSQL* server parameters might be different, too.

To achieve the best performance, almost all the required data (tables and indexes) for the ongoing workload should be able to reside within the file system cache. Monitoring the I/O activity will help to identify insufficient memory resources.

The IOM is built with Hibernate as an API between the application logic and the database. This mainly results in a strong OLTP activity, with a large number of tiny SQL statements. Larger statements occur during import/export jobs and for some OMT search requests.

The following main parameters in *$PGDATA/data/postgresql.conf* should be adapted, see `PostgreSQL 12 | Chapter 19. Server Configuration <https://www.postgresql.org/docs/12/static/runtime-config-resource.html>`_.

You can consider `PGConfig 2.0 <http://www.pgconfig.org/>`_ as a guideline (using the OLTP Model).

Some aspects of data reliability are discussed in `PostgreSQL 12 | Chapter 29. Reliability and the Write-Ahead Log <https://www.postgresql.org/docs/12/static/wal.html>`_. Understanding VACUUM is also essential when configuring/monitoring Postgres, see `PostgreSQL 12 | Chapter 24. Routine Database Maintenance Tasks <https://www.postgresql.org/docs/12/static/routine-vacuuming.html>`_.
  
+----------------------------------------+-----------------------------------------------------------------------------------------------+
|Parameter                               |Description                                                                                    |
|                                        |                                                                                               |
+========================================+===============================================================================================+
|max_connections                         |The number of concurrent connections from the application is controlled by the parameters      |
|                                        |*jboss.xaPoolsizeMin* and *jboss.xaPoolsizeMax*.  Some connections will take place beside this |
|                                        |pool, mainly for job tasks like import/export. Make sure that *max_connection* is set higher   |
|                                        |here than the according IOM parameters.                                                        |
|                                        |                                                                                               |
|                                        |.. note::                                                                                      |
|                                        |                                                                                               |
|                                        |  Highly concurrent connections have a negative impact on performance. It is more              |
|                                        |  efficient to queue the requests than to process them all in parallel.                        |
+----------------------------------------+-----------------------------------------------------------------------------------------------+
|max_prepared_transactions               |Required for IOM installations. Set its value to about 150% of *max_connections*.              |
|                                        |                                                                                               |
|                                        |                                                                                               |
+----------------------------------------+-----------------------------------------------------------------------------------------------+
|shared_buffers                          |Between 1/4 and 1/3 of the total RAM, but not more than about 8 GB. Otherwise, the cache       |
|                                        |management will use too many resources. The remaining RAM is more valuable as a file system    |
|                                        |cache.                                                                                         |
+----------------------------------------+-----------------------------------------------------------------------------------------------+
|work_mem                                |Higher *work_mem* can increase performance significantly. The default is way too low. Consider |
|                                        |using 100-400 MB.                                                                              |
|                                        |                                                                                               |
+----------------------------------------+-----------------------------------------------------------------------------------------------+
|maintenance_work_mem                    |Increase the default similar to *work_mem* to favor quicker vacuums. With IOM, this parameter  |
|                                        |will be used almost exclusively for this task (unless you also set *autovacuum_work_mem*).     |
|                                        |Consider something like 2% of your total RAM per autovacuum_max_workers. e.g., 32GB RAM * 2% * |
|                                        |3 workers = 2GB.                                                                               |
+----------------------------------------+-----------------------------------------------------------------------------------------------+
|vacuum_cost_*                           |The feature can stay disabled at the beginning. You should keep an eye on the vacuum activity  |
|                                        |under high load.                                                                               |
|                                        |                                                                                               |
+----------------------------------------+-----------------------------------------------------------------------------------------------+
|wal_level                               |Depends on your backup, recovery, and failover strategy. Should be at least *archive*.         |
|                                        |                                                                                               |
|                                        |                                                                                               |
+----------------------------------------+-----------------------------------------------------------------------------------------------+
|wal_sync_method                         |Depends on your platform, check `PostgreSQL 12 | 19.5. Write Ahead Log | wal_sync_method (enum)|
|                                        |<https://www.postgresql.org/docs/12/static/runtime-config-wal.html#GUC-WAL-SYNC-METHOD>`_.     |
|                                        |                                                                                               |
+----------------------------------------+-----------------------------------------------------------------------------------------------+
|max_wal_size                            |8 (small system) - 128 (large system)                                                          |
|                                        |                                                                                               |
|                                        |                                                                                               |
+----------------------------------------+-----------------------------------------------------------------------------------------------+
|max_parallel_workers (since Postgres    |0                                                                                              |
|9.6)                                    |                                                                                               |
|                                        |                                                                                               |
+----------------------------------------+-----------------------------------------------------------------------------------------------+
|checkpoint_completion_target            |Use 0.8 or 0.9.                                                                                |
|                                        |                                                                                               |
|                                        |                                                                                               |
+----------------------------------------+-----------------------------------------------------------------------------------------------+
|archive_* and REPLICATION               |Depends on your backup & failover strategy.                                                    |
|                                        |                                                                                               |
|                                        |                                                                                               |
+----------------------------------------+-----------------------------------------------------------------------------------------------+
|random_page_cost                        |The default (4) is usually too high. Better choose 2.5 or 3.                                   |
|                                        |                                                                                               |
|                                        |                                                                                               |
+----------------------------------------+-----------------------------------------------------------------------------------------------+
|effective_cache_size                    |Indicates the expected size of the file system cache. On a dedicated server: should be about   |
|                                        |*total_RAM* - *shared_buffers* - 1GB.                                                          |
|                                        |                                                                                               |
+----------------------------------------+-----------------------------------------------------------------------------------------------+
|log_min_duration_statement              |Set it between 1 and 5 seconds to help track long-running queries.                             |
|                                        |                                                                                               |
|                                        |                                                                                               |
+----------------------------------------+-----------------------------------------------------------------------------------------------+
|log_filename                            |Better use an explicit name to help when communicating, e.g.,                                  |
|                                        |``pg-IOM_host_port-%Y%m%d_%H%M.log``.                                                          |
|                                        |                                                                                               |
|                                        |Not applicable if the *PostgreSQL* server is running in Kubernetes since all messages are      |
|                                        |written to stdout in this case.                                                                |
+----------------------------------------+-----------------------------------------------------------------------------------------------+
|log_rotation_age                        |Set it to 60 min or less.                                                                      |
|                                        |                                                                                               |
|                                        |Not applicable if the *PostgreSQL* server is running in Kubernetes since all messages are      |
|                                        |written to stdout in this case.                                                                |
+----------------------------------------+-----------------------------------------------------------------------------------------------+
|log_line_prefix                         |Better use a more verbose format than the default, e.g., ``%m|%a|%c|%p|%u|%h|``.               |
|                                        |                                                                                               |
|                                        |                                                                                               |
+----------------------------------------+-----------------------------------------------------------------------------------------------+
|log_lock_waits                          |Activate it (=on).                                                                             |
|                                        |                                                                                               |
|                                        |                                                                                               |
+----------------------------------------+-----------------------------------------------------------------------------------------------+
|stats_temp_directory                    |Better redirect it to a RAM disk.                                                              |
|                                        |                                                                                               |
|                                        |                                                                                               |
+----------------------------------------+-----------------------------------------------------------------------------------------------+
|log_autovacuum_min_duration             |Set it to a few seconds to monitor the vacuum activity.                                        |
|                                        |                                                                                               |
|                                        |                                                                                               |
+----------------------------------------+-----------------------------------------------------------------------------------------------+
|idle_in_transaction_session_timeout.    |An equivalent parameter exists for the WildFly connection pool (query-timeout) where it is set |
|(since Postgres 9.6)                    |to 1 hour per default. Set *idle_in_transaction_session_timeout* to a larger value, e.g., 9    |
|                                        |hours, to clean up possible leftover sessions.                                                 |
+----------------------------------------+-----------------------------------------------------------------------------------------------+
								 
.. topic:: Navigation

  `< Back <SecretKeyRef.rst>`_ | `^ Up <../README.rst>`_ | `Next > <IOMDatabase.rst>`_
