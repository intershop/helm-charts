+---------------------+-----------------+----------------------------+
|`< Back              |`^ Up            |`Next >                     |
|<ParametersIOM.rst>`_|<../README.rst>`_|<ParametersPostgres.rst>`_  |
+---------------------+-----------------+----------------------------+

================================================
Helm Charts for Intershop Order Management (IOM)
================================================

------------------------------------
Parameters of Integrated SMTP Server
------------------------------------

A complete list of parameters can be found here: https://github.com/jouve/charts/tree/main/charts/mailpit

The table below only lists parameters that have to be changed for different operation options of IOM.

+----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|Parameter                               |Description                                                                                    |Default Value                                 |
|                                        |                                                                                               |                                              |
+========================================+===============================================================================================+==============================================+
|mailpit.enabled                         |Controls whether an integrated SMTP server should be used or not. This SMTP server is not      |false                                         |
|                                        |intended to be used for any kind of serious IOM installation. It should only be used for demo-,|                                              |
|                                        |CI- or similar types of setups.                                                                |                                              |
+----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|mailpit.resources                       |Resource requests & limits.                                                                    |.. code-block:: yaml                          |
|                                        |                                                                                               |                                              |
|                                        |                                                                                               |    limits:                                   |
|                                        |                                                                                               |      cpu: 100m                               |
|                                        |                                                                                               |      memory: 64Mi                            |
|                                        |                                                                                               |    requests:                                 |
|                                        |                                                                                               |      cpu: 100m                               |
|                                        |                                                                                               |      memory: 64Mi                            |
+----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|mailpit.ingress.ingressClassName        |Class of Ingress Controller to be used.                                                        |nginx                                         |
+----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|mailpit.ingress.hostname                |Hostname that provides Mailpit UI and API.                                                     |mail-test.poc.intershop.de                    |
+----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|mailpit.ingress.annotations             |Annotations for the ingress.                                                                   |{}                                            |
+----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+

+---------------------+-----------------+--------------------------+
|`< Back              |`^ Up            |`Next >                   |
|<ParametersIOM.rst>`_|<../README.rst>`_|<ParametersPostgres.rst>`_|
+---------------------+-----------------+--------------------------+
