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
10. `Prometheus Metrics <docs/Metrics.rst>`_
11. `PostgreSQL Server Configuration <docs/Postgresql.rst>`_
12. `Options and Requirements of IOM Database <docs/IOMDatabase.rst>`_

======================
Dependency Information
======================

For the best compatibility between IOM Helm Charts and IOM, please always use the newest version of IOM Helm Charts,
regardless of the IOM version you are currently using. Therefore, update IOM Helm Charts as often as possible.

The current version of Helm Charts is backward compatible with all versions of IOM since 3.5. But only the newest
IOM version, which is 4.3.0 at the time of writing, supports all features that the Helm Charts are offering. For more
information, please consult the reference documentation of `Helm parameters of IOM <docs/ParametersIOM.rst>`_.

..
   Table is commented out, it's used as an internal reference only.

   +-------------+-----+-----+-----+-----+-----+-----+-----+
   |Helm / IOM   |3.5  |3.6  |3.7  |4.0  |4.1  |4.2  |4.3  |
   |             |     |     |     |     |     |     |     |
   +=============+=====+=====+=====+=====+=====+=====+=====+
   |**2.3**      |[1]_ |[2]_ |[3]_ |[3]_ |[3]_ |[3]_ |     |
   |             |[3]_ |[3]_ |     |     |     |     |     |
   +-------------+-----+-----+-----+-----+-----+-----+-----+
   |**2.2**      |[1]_ |[2]_ |     |     |     |     |     |
   |             |     |     |     |     |     |     |     |
   +-------------+-----+-----+-----+-----+-----+-----+-----+
   |**2.1**      |[1]_ |[2]_ |     |     |     |     |     |
   |             |     |     |     |     |     |     |     |
   +-------------+-----+-----+-----+-----+-----+-----+-----+
   |**2.0**      |[1]_ |[2]_ |     |     |x    |x    |x    |
   |             |     |     |     |     |     |     |     |
   +-------------+-----+-----+-----+-----+-----+-----+-----+

   x: not supported

   .. [1] Helm parameters *log.rest*, *config.skip*, *oms.db.connectionMonitor.*, *oms.db.connectTimeout* do not work in this combination.
   .. [2] Helm parameter *jboss.activemqClientPoolSizeMax* does not work in this combination.
   .. [3] Helm parameters *oms.sso.\** do not work in this combination.

=============
Version 2.3.0
=============

------------
New Features
------------

Added Support for *Single Sign-On* (SSO)
=================================================

You can now configure *single sign-on* (SSO) via the new parameter group *oms.sso*.
There are four new parameters that control the configuration of IOM in combination with an Identity and
Access Management System: *oms.sso.enabled*, *oms.sso.type*, *oms.sso.oidcConfig*, and
*oms.sso.oidcConfigSecretKeyRef*.

Using *SSO*-parameters requires IOM 4.3.0 or newer.

For a detailed description of these parameters, see `Helm parameters of IOM <docs/ParametersIOM.rst>`_.

---------------
Migration Notes
---------------

Changed default values of *image.tag* and *dbaccount.image.tag*
===============================================================

Default value of IOM version (parameter *image.tag*) was changed to 4.3.0 and default value of dbaccount version
(parameter *dbaccount.image.tag*) was updated to 1.6.0.

=============
Version 2.2.0
=============

------------
New Features
------------

Added New Parameter *podDisruptionBudget.maxUnavailable*
=================================================================

*PodDisruptionBudget* has been added to IOM Helm Charts. *PodDisruptionBudgets* defines the behavior of pods during a
voluntary disruption of the Kubernetes Cluster. The default value of the parameter *podDisruptionBudget.maxUnavailable*
is 1, which guarantees that only one IOM pod will be unavailable during a voluntary disruption of the Kubernetes cluster.

See also `Helm parameters of IOM <docs/ParametersIOM.rst>`_.

Added New Parameter-Group *podAntiAffinity*
====================================================

Parameter-group *podAntiAffinity*, along with the according default values, prevents scheduling of more than one IOM
pod of current helm release onto one node. In this way, the IOM deployment is secured against failures of a single node.

See also `Helm parameters of IOM <docs/ParametersIOM.rst>`_.

Added New Parameter-Group *spreadPods*
===============================================

*spreadPods* provides an alternative or additional method to spread IOM pods over nodes. Contrary to *podAntiAffinity*
it is possible to run more than one pod per node. For example, if there are two nodes and four pods, the pods are evenly spread across the
nodes. Each node is running two pods. Additionally, it is very easy to combine different topologies.

Unlike *podAntiAffinity*, *spreadPods* is disabled by default.

See also `Helm parameters of IOM <docs/ParametersIOM.rst>`_.

---------------
Migration Notes
---------------

*podAntiAffinity* is Enabled and Uses *mode: required* by Default
=================================================================

*podAntiAffinity* is enabled and uses *mode: required* by default, which makes the IOM deployment instantly more robust against
failures of a single node. Each IOM pod requires its own node in this case. However, if the corresponding Kubernetes cluster does not provide
the required number of nodes, the deployment of IOM will fail.

Please check your cluster in advance. If the capacity is not sufficient, please use *podAntiAffinity.mode: preferred* instead.

Changed Default Value of *startupProbe.failureThreshold*
===========================================================

The default value of *startupProbe.failureThreshold* has been increased from 60 to 354, which increases the default timeout for database
initialization and migration from 11 minutes to one hour. If the new default value does not meet the requirements, you must set
the right value within the values file.

See also `Helm parameters of IOM <docs/ParametersIOM.rst>`_.

Changed Default Values of *image.repository* and *dbaccount.image.repository*
==================================================================================

The default values of *image.repository* and *dbaccount.image.repository* now both point to the new Intershop Docker
repository at *docker.tools.intershop.com*. If you use the default values of these parameters, you need to create a
pull-secret, which has to be set at *imagePullSecrets*.

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
