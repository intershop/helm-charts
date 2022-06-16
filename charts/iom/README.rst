.. Can be locally rendered by "restview README.rst".
   Requires port py-rstcheck

================================================
Helm Charts for Intershop Order Management (IOM)
================================================

The following documents provide an extensive documentation how to operate IOM with IOM Helm Charts:

1.  `Tools & Concepts <docs/ToolsAndConcepts.rst>`_
2.  `Example: local Demo running in Docker-Desktop <docs/ExampleDemo.rst>`_
3.  `Example: Production System in AKS <docs/ExampleProd.rst>`_
4.  `Helm parameters of IOM <docs/ParametersIOM.rst>`_
5.  `Helm parameters of Integrated SMTP server <docs/ParametersMailhog.rst>`_
6.  `Helm parameters of Integrated NGINX Ingress Controller <docs/ParametersNGINX.rst>`_
7.  `Helm parameters of Integrated PostgreSQL Server <docs/ParametersPosgres.rst>`_
8.  `Helm parameters of IOM-Tests <docs/ParametersTests.rst>`_
9.  `References to Kubernetes Secrets <docs/SecretKeyRef.rst>`_
10. `PostgreSQL Server Configuration <docs/Postgresql.rst>`_
11. `Options and Requirements of IOM Database <docs/IOMDatabase.rst>`_

======================    
Dependency Information
======================

For the best compatibility between IOM Helm charts and IOM, please always use the newest version of IOM Helm charts,
regardless of the IOM version you are currently using. To do so, please update IOM Helm charts as often as possible.

+-----+-----+-----+-----+-----+-----+
|Helm |3.5  |3.6  |3.7  |4.0  |4.1  |
|/ IOM|     |     |     |     |     |
|     |     |     |     |     |     |
+=====+=====+=====+=====+=====+=====+
|2.2  |[1]_ |[2]_ |     |     |     |
|     |     |     |     |     |     |
|     |     |     |     |     |     |
+-----+-----+-----+-----+-----+-----+
|2.1  |[1]_ |[2]_ |     |     |     |
|     |     |     |     |     |     |
|     |     |     |     |     |     |
+-----+-----+-----+-----+-----+-----+
|2.0  |[1]_ |[2]_ |     |     |x    |
|     |     |     |     |     |     |
|     |     |     |     |     |     |
+-----+-----+-----+-----+-----+-----+

x: not supported

.. [1] Helm parameters *log.rest*, *config.skip*, *oms.db.connectionMonitor.*, *oms.db.connectTimeout* do not work in this combination.
.. [2] Helm parameter *jboss.activemqClientPoolSizeMax* does not work in this combination


=============
Known Defects
=============

