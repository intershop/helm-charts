+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------+
|Parameter                               |Description                                                                     |Default Value                           |
|                                        |                                                                                |                                        |
+========================================+================================================================================+========================================+
|replicaCount                            |The number of IOM application server instances to run in parallel.              |2                                       |
|                                        |                                                                                |                                        |
|                                        |                                                                                |                                        |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------+
|downtime                                |The *downtime* parameter is a very critical one. Its goal and behavior is       |true                                    |
|                                        |already described in [Restrictions on Upgrade](TODO).                           |                                        |
|                                        |                                                                                |                                        |
|                                        |Additional information:                                                         |                                        |
|                                        |                                                                                |                                        |
|                                        |* If *downtime* is set to *false*, the DBmigrate process, as part of the process|                                        |
|                                        |  the config init-container is executing, is skipped. This has no impact on the |                                        |
|                                        |  project configuration.                                                        |                                        |
|                                        |                                                                                |                                        |
|                                        |* For the *downtime* parameter to work correctly, the `--wait` and `--timeout`  |                                        |
|                                        |  command line parameters must always be set when running Helm.                 |                                        |
|                                        |                                                                                |                                        |
|                                        |                                                                                |                                        |
|                                        |                                                                                |                                        |
|                                        |                                                                                |                                        |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------+
|                                        |                                                                                |                                        |
|                                        |                                                                                |                                        |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------+
|                                        |                                                                                |                                        |
|                                        |                                                                                |                                        |
+----------------------------------------+--------------------------------------------------------------------------------+----------------------------------------+
