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

-------------
Known Defects
-------------

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

-------------
Known Defects
-------------

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
