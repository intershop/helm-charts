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

+-------------+-----+-----+-----+-----+-----+
|Helm / IOM   |3.5  |3.6  |3.7  |4.0  |4.1  |
|             |     |     |     |     |     |
+=============+=====+=====+=====+=====+=====+
|**2.2**      |[1]_ |[2]_ |     |     |     |
|             |     |     |     |     |     |
+-------------+-----+-----+-----+-----+-----+
|**2.1**      |[1]_ |[2]_ |     |     |     |
|             |     |     |     |     |     |
+-------------+-----+-----+-----+-----+-----+
|**2.0**      |[1]_ |[2]_ |     |     |x    |
|             |     |     |     |     |     |
+-------------+-----+-----+-----+-----+-----+

x: not supported

.. [1] Helm parameters *log.rest*, *config.skip*, *oms.db.connectionMonitor.*, *oms.db.connectTimeout* do not work in this combination.
.. [2] Helm parameter *jboss.activemqClientPoolSizeMax* does not work in this combination

=============
Version 2.2.0
=============

------------
New Features
------------

New Parameter *podDisruptionBudget.maxUnavailable* has been added
=================================================================

*PodDisruptionBudget* has been added to IOM Helm Charts. *PodDisruptionBudgets* define the behavior of pods during a
voluntary disruption of the Kubernetes Cluster. The default value of parameter *podDisruptionBudget.maxUnavailable*
is 1, which guarantees that only one IOM pod will be unavailable during a voluntary disruption of the Kubernetes cluster.

See also `Helm parameters of IOM <docs/ParametersIOM.rst>`_.

New Parameter-Group *podAntiAffinity* has been added
====================================================

Parameter-group *podAntiAffinity* along with the according default values, prevents scheduling of more than one IOM
pod of current helm release onto one node. This way the IOM deployment becomes robuts againts failures of a single node.

See also `Helm parameters of IOM <docs/ParametersIOM.rst>`_.

New Parameter-Group *spreadPods* has been added
===============================================

*spreadPods* provides an alternative or additional method to spread IOM pods over nodes. In difference to *podAntiAffinity*
it is possible to run more than one pod per node. E.g. if there are 2 nodes and 4 pods the pods are evenly spread over the
nodes. Each node is then running 2 pods. Additionally it is very easy to combine different topologies.

In difference to *podAntiAffinity*, *spreadPods* is disabled on default.

See also `Helm parameters of IOM <docs/ParametersIOM.rst>`_.

---------------
Migration Notes
---------------

*podAntiAffinity* is enabled and uses *mode: required* on default
=================================================================

*podAntiAffinity* is enabled and uses *mode: required* on default, which makes the IOM deployment instantly more robust against
failures of a single node. Each IOM pod requires it's own node in this case. But, if the according Kubernetes cluster does not provide
the required number of nodes, the deployment of IOM will fail.

Please check your cluster in advance. If the capacity is not sufficient, please use *podAntiAffinity.mode: preferred* instead.

Default value of *startupProbe.failureTreshold* was changed
===========================================================

The default value of *startupProbe.failureTreshold* was increased from 60 to 354, which increases the default timeout for database
initialization and migration from 11 minutes to one hour. If the new default value is not matching the requirements, you have to set
the right value within the values file.

See also `Helm parameters of IOM <docs/ParametersIOM.rst>`_.

Default values of *image.repository* and *dbaccount.image.repository* have changed
==================================================================================

The default values of *image.repository* and *dbaccount.image.repository* are now both referencing the new Intershop Docker
repository at *docker.tools.intershop.com*. If you are using the default values of these parameters, you need to create a
pull-secret, which has to set at *imagePullSecrets*.

-------------
Fixed Defects
-------------

+--------+------------------------------------------------------------------------------------------------+
|Key     |Summary                                                                                         |
|        |                                                                                                |
+========+================================================================================================+
|78274   |*imagePullSecrets* were missing in job-spec of connection-monitor.                              |
|        |                                                                                                |
+--------+------------------------------------------------------------------------------------------------+

-------------
Removal Notes
-------------

Helm parameter *oms.mailResourcesBaseUrl* has been removed.
       
=============
Known Defects
=============

+--------+------------------------------------------------------------------------------------------------+
|Key     |Summary                                                                                         |
|        |                                                                                                |
+========+================================================================================================+
|69933   |It is not possible to use the internal NGINX in combination with a global NGINX                 |
|        |ingress-controller                                                                              |
|        |                                                                                                |
+--------+------------------------------------------------------------------------------------------------+
|76294   |Internal NGINX ingress-controller cannot use custom ingress-class nginx-iom (it is using class  |
|        |nginx instead)                                                                                  |
|        |                                                                                                |
+--------+------------------------------------------------------------------------------------------------+

Helm parameter *oms.mailResourcesBaseUrl* was removed.
       
=============
Known Defects
=============

+--------+------------------------------------------------------------------------------------------------+
|Key     |Summary                                                                                         |
|        |                                                                                                |
+========+================================================================================================+
|69933   |It is not possible to use the internal NGINX in combination with a global NGINX                 |
|        |ingress-controller                                                                              |
|        |                                                                                                |
+--------+------------------------------------------------------------------------------------------------+
|76294   |Internal NGINX ingress-controller cannot use custom ingress-class nginx-iom (it is using class  |
|        |nginx instead)                                                                                  |
|        |                                                                                                |
+--------+------------------------------------------------------------------------------------------------+

