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

A complete list of parameters can be found here: https://github.com/codecentric/helm-charts/tree/master/charts/mailhog

The table below only lists parameters that have to be changed for different operation options of IOM.

+----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|Parameter                               |Description                                                                                    |Default Value                                 |
|                                        |                                                                                               |                                              |
+========================================+===============================================================================================+==============================================+
|mailhog.enabled                         |Controls whether an integrated SMTP server should be used or not. This SMTP server is not      |false                                         |
|                                        |intended to be used for any kind of serious IOM installation. It should only be used for demo-,|                                              |
|                                        |CI- or similar types of setups.                                                                |                                              |
+----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|mailhog.probes.enabled                  |This parameter allows to switch on/off liveness and readiness probes of Mailhog. These probes  |true                                          |
|                                        |are producing a lot of messages, which can be avoided if the probes are disabled.              |                                              |
|                                        |                                                                                               |                                              |
+----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|mailhog.resources                       |Resource requests & limits.                                                                    |{}                                            |
|                                        |                                                                                               |                                              |
|                                        |                                                                                               |                                              |
+----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|mailhog.ingress.hosts                   |A list of ingress hosts.                                                                       |.. code-block:: yaml                          |
|                                        |                                                                                               |                                              |
|                                        |                                                                                               |  - host: mailhog-test.poc.intershop.de       |
|                                        |                                                                                               |    paths:                                    |
|                                        |                                                                                               |      - path: /                               |
|                                        |                                                                                               |        pathType: Prefix                      |
|                                        |                                                                                               |                                              |
+----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|mailhog.ingress.tls                     |A list of IngressTLS items.                                                                    |[]                                            |
|                                        |                                                                                               |                                              |
|                                        |                                                                                               |                                              |
+----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|mailhog.ingress.annotations             |Annotations for the ingress.                                                                   |{}                                            |
|                                        |                                                                                               |                                              |
|                                        |                                                                                               |                                              |
+----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+

+---------------------+-----------------+-------------------------+
|`< Back              |`^ Up            |`Next >                  |
|<ParametersIOM.rst>`_|<../README.rst>`_|<ParametersNGINX.rst>`_  |
+---------------------+-----------------+-------------------------+
