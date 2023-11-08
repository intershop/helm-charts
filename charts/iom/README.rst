.. Can be locally rendered by "restview README.rst".
   Requires port py-rstcheck

================================================
Helm Charts for Intershop Order Management (IOM)
================================================

The following documents provide an extensive documentation how to operate IOM with IOM Helm Charts:

1. `Tools & Concepts <docs/ToolsAndConcepts.rst>`_
#. `Example: local Demo running in Docker-Desktop <docs/ExampleDemo.rst>`_
#. `Example: Production System in AKS <docs/ExampleProd.rst>`_
#. `Helm parameters of IOM <docs/ParametersIOM.rst>`_
#. `Helm parameters of Integrated SMTP server <docs/ParametersMailhog.rst>`_
#. `Helm parameters of Integrated PostgreSQL Server <docs/ParametersPosgres.rst>`_
#. `Helm parameters of IOM-Tests <docs/ParametersTests.rst>`_
#. `References to Kubernetes Secrets <docs/SecretKeyRef.rst>`_
#. `Persistent Storage <docs/PersistentStorage.rst>`_
#. `Prometheus Metrics <docs/Metrics.rst>`_
#. `PostgreSQL Server Configuration <docs/Postgresql.rst>`_
#. `Options and Requirements of IOM Database <docs/IOMDatabase.rst>`_

======================
Dependency Information
======================

For the best compatibility between IOM Helm Charts and IOM, please always use the newest version of IOM Helm Charts,
regardless of the IOM version you are currently using. Therefore, update IOM Helm Charts as often as possible.

The current version of Helm Charts is backward compatible with all versions of IOM since 4.0. But only the newest
IOM version, which is 4.8.0 at the time of writing, supports all features that the Helm Charts are offering. For more
information, please consult the reference documentation of `Helm parameters of IOM <docs/ParametersIOM.rst>`_.

..
   Table is commented out, it's used as an internal reference only.

   +-------------+-----+-----+-----+-----+-----+-----+-------+-------+
   |Helm / IOM   |3.5  |3.6  |3.7  |4.0  |4.1  |4.2  |4.3-4.7|4.8    |
   |             |     |     |     |     |     |     |       |       |
   +=============+=====+=====+=====+=====+=====+=====+=======+=======+
   |**3.0**      |x    |x    |x    |[3]_ |[3]_ |[3]_ |[4]_   |       |
   |             |     |     |     |[4]_ |[4]_ |[4]_ |       |       |
   +-------------+-----+-----+-----+-----+-----+-----+-------+-------+
   |**2.3**      |[1]_ |[2]_ |[3]_ |[3]_ |[3]_ |[3]_ |       |       |
   |             |[3]_ |[3]_ |     |     |     |     |       |       |
   +-------------+-----+-----+-----+-----+-----+-----+-------+-------+
   |**2.2**      |[1]_ |[2]_ |     |     |     |     |       |       |
   |             |     |     |     |     |     |     |       |       |
   +-------------+-----+-----+-----+-----+-----+-----+-------+-------+
   |**2.1**      |[1]_ |[2]_ |     |     |     |     |       |       |
   |             |     |     |     |     |     |     |       |       |
   +-------------+-----+-----+-----+-----+-----+-----+-------+-------+
   |**2.0**      |[1]_ |[2]_ |     |     |x    |x    |x      |x      |
   |             |     |     |     |     |     |     |       |       |
   +-------------+-----+-----+-----+-----+-----+-----+-------+-------+

   x: not supported

   .. [1] Helm parameters *log.rest*, *config.skip*, *oms.db.connectionMonitor.*, *oms.db.connectTimeout* do not work in this combination.
   .. [2] Helm parameter *jboss.activemqClientPoolSizeMax* does not work in this combination.
   .. [3] Helm parameters *oms.sso.\** do not work in this combination.
   .. [4] Helm parameters *newRelic.\** do not work in this combination 

=============
Version 3.0.0
=============

------------
New Features
------------

Update of mailhog sub-chart
===========================

Mailhog sub-chart was updated to version 5.2.3.

Added Support for *New Relic APM*
=================================

Helm Charts of version 3.0 are now supporting the usage of *New Relic APM* (Application Performance Monitoring). *New
Relic APM* can be managed by new Helm paramters within parameter-group *newRelic*.

For a description of all new Parameters in detail, please see `Helm parameters of IOM <docs/ParametersIOM.rst>`_.

The usage of *New Relic APM* requires the usage of IOM version 4.8.0 or newer.

Random JWT-secret provided
==========================

On default a secret for JWT is created automatically, containing a random value.

It is still possible to define custom values, by using the parameters *oms.jwtSecret* and *oms.jwtSecretKeyRef*.

Handling of persistent storage for shared file-system was improved
==================================================================

The configuration and documentation of persistent storage for shared file-system was improved.

A new documentation page "`Persistent Storage <docs/PersistentStorage.rst>`_" was added, that describes the configuration of
shared file-system in detail. Documentation of "`Helm Parameters of IOM <docs/ParametersIOM.rst>`_" was updated.

Please note, that the new configuration requires migration of Helm parameters. 

---------------
Migration Notes
---------------

Removal of internal NGINX
=========================

Internal NGINX, which was an optional component of IOM Helm Charts, was removed. The internal NGINX could be used in the
following cases:

1. The main goal of the internal NGINX was to act as a proxy between Ingress controller and IOM application servers in case,
   the Ingress controller had no ability to provide session stickiness. In this case, the internal NGINX was able to
   handle session stickiness for IOM.
2. In very simple demo and test installations, the internal NGINX could also be used as Ingress controller. This made the
   setup easier, since the installation of a cluster wide Ingress controller could be skipped.

If an installation is currently using the internal NGINX (parameter *nginx.enabled* is set to *true*), then measures
have to be taken before using IOM Helm Charts 3.0.0. Depending on the use-case, which leads to the usage of the internal
NGINX, the measures are different.

1. Session stickiness has to be provided by the Ingress controller, otherwise IOM can not be operated. If an NGINX Ingress
   controller is used, the IOM Helm Charts already provide the required configuration settings. If any other Ingress
   controller is used, you have to determine how to configure it in order to provide session stickiness. The according
   configuration has then to be applied in the Helm values.
2. Simple demo and test installations now have to use a separately installed Ingress controller. Preferred is an NGINX
   Ingress controller, since the required configuration for session stickiness is already provided by IOM Helm Charts.

Default value of *mailhog.probes.enabled* has changed
=====================================================

The default value of *mailhog.probes.enabled* was changed from *true* to *false*, meaning that there are no probes executed
unless requested. This new setting reduces the amount of log-messages of mailhog even if default values are used.

*dbaccount.resetData* was replaced by *oms.db.resetData*
========================================================

Parameter *dbaccount.resetData* was replaced by *oms.db.resetData*. For a limited period of time (until the next major release of IOM
Helm charts), the old parameter *dbaccount.resetData* will still be supported.
Usage of new parameter *oms.db.resetData* requires IOM version 4.8.0 or newer.

See also `Helm parameters of IOM <docs/ParametersIOM.rst>`_.

Default value of *oms.jwtSecret* has changed
============================================

The default value of *oms.jwtSecret* is empty now, causing the usage of an automatically created random secret. That means, if you
have not set *oms.jwtSecret* and *oms.jwtSecretKeyRef*, this automatically created secret will be used instead. 

See also `Helm parameters of IOM <docs/ParametersIOM.rst>`_.

Handling of persistent storage for shared file-system was improved
==================================================================

In former version of IOM Helm charts the provisioning of persistent storage method was depending on the two parameters *persistence.hostPath*
and *persistence.storageClass*. There was also a third parameter (*persistence.pvc*), but this
one was removed. There was a precedence defined for these parameters to select the provisioning method: if *persistence.hostPath* was set,
*persistence.storageClass* was ignored.

This is now changed. The new parameter *persistence.provisioning* was introduced, that explicitely defines the provisiong method to be used.
Allowed values for *persistence.provisioning* are *dynamic* (default), *static* and *local*.

- *dynamic* is equivalent to an old configuration, where *persistence.hostPath* and *persistence.pvc* were both not set.
- *static* is a new provisioning method, that was not supported by older versions of IOM Helm charts.
- *local* is equivalent to an old configuration, where *persistence.hostPath* was set, but *persistence.pvc* was not.

Each provisioning method can be configured in more detail. Therefore separate parameter-groups were introduced, which mirror the names
of the provisioning methods: *persistence.dynamic|static|local*.

The old parameter *persistence.storageClass* belongs to *dynamic* provisioning, therefore it was moved to *persistence.dynamic.storageClass*.
The old parameter *persistence.hostPath*, belongs to *local* provisioning and was therefore
moved to parameter *persistence.local.hostPath*.

The former parameter *persistence.annotations* was split into three different parameters, one
for each provisioning method: *persistence.dynamic|static|local.annotations*. This
way it became possible to define different default-annotations for the different provisioning methods.

In former version of IOM Helm charts the following annotations for *persistent-volume-claim* were used in every case:

.. code-block:: yaml

    "helm.sh/resource-policy": keep
    "helm.sh/hook": pre-install

In the current version of IOM Helm charts, there are no default-annotations at all for *persistence.static.annotations* and *persistence.local.annotations*.
Only in case of *dynamic* provisioning, there is a single default-annotation:

.. code-block:: yaml

    "helm.sh/resource-policy": keep

Examples for migrations
-----------------------

+----------------------------------------+------------------------------------------+
|Old                                     |Migrated                                  |
|configuration                           |configuration                             |
+========================================+==========================================+
|Dynamic provisioning of persistent storage using *storage-class* *azurefile*,      |
|automatic deletion of *pvc* is prevented.                                          |
|                                                                                   |
|Preventing deletion of *pvc* and usage of *storage-class* *azurefile* are the      |
|default behavior. Old and new configuration are identical.                         |
+----------------------------------------+------------------------------------------+
|.. code-block:: yaml                    |.. code-block:: yaml                      |
|                                        |                                          |
|  persistence:                          |  persistence:                            |
|                                        |                                          |
+----------------------------------------+------------------------------------------+
|Dynmaic provisioning of persistent storage using a custom *storage-class*,         |
|automatic deletion of *pvc* is prevented.                                          |
|                                                                                   |
|Preventing deletion of *pvc* is the default behavior in both cases, therefore      |
|annotations are not specified in both cases. The position of *storageClass* has    |
|changed, it has to be moved to *persistence.dynamic.storageClass*.                 |
+----------------------------------------+------------------------------------------+
|.. code-block:: yaml                    |.. code-block:: yaml                      |
|                                        |                                          |
|  persistence:                          |  persistence:                            |
|    storageClass: azurefile-iom         |    dynamic:                              |
|                                        |      storageClass: azurefile-iom         |
+----------------------------------------+------------------------------------------+
|Dynamic provisioning of persistent storage using *storage-class* *azurefile*,      |
|automatic deletion of *pvc* is enabled.                                            |
|                                                                                   |
|Enabling deletion of *pvc* is done by removing all annotations from *pvc*. This has|
|not changed in the new version. But the position has changed from                  |
|*persistence.annotations* to *persistence.dynamic.annotations*.                    |
|                                                                                   |
|Since *azurefile* is and was the default-value of *storageClass* and dynamic       |
|provisioning is the default provisioning method, the other parts of old and new    |
|configuration have not changed.                                                    |
+----------------------------------------+------------------------------------------+
|.. code-block:: yaml                    |.. code-block:: yaml                      |
|                                        |                                          |
|  persistence:                          |  persistence:                            |
|    annotations:                        |    dynamic:                              |
|                                        |      annotations:                        |
+----------------------------------------+------------------------------------------+
|Dynamic provisioning of persistent storage using a custom *storage-class*,         |
|automatic deletion of *pvc* is enabled.                                            |
|                                                                                   |
|Enabling deletion pf *pvc* is done by removing all annotations from *pvc*. This has|
|not changed in the new version. But the position has changed from                  |
|*persistence.annotations* to *persistence.dynamic.annotations*.                    |
|                                                                                   |
|Parameter *persistence.storageClass* has moved in the new version to               |
|*persistence.dynamic.storageClass*.                                                |
+----------------------------------------+------------------------------------------+
|.. code-block:: yaml                    |.. code-block:: yaml                      |
|                                        |                                          |
|  persistence:                          |  persistence                             |
|    storageClass: azurefile-iom         |    dynamic:                              |
|    annotations:                        |      storageClass: azurefile-iom         |
|                                        |      annotations:                        |
+----------------------------------------+------------------------------------------+
|Local provisioning of persistent storage.                                          |
|                                                                                   |
|Parameter *persistence.hostPath* has moved in the new version to                   |
|*persistence.local.hostPath*.                                                      |
+----------------------------------------+------------------------------------------+
|.. code-block:: yaml                    |.. code-block:: yaml                      |
|                                        |                                          |
|  persistence:                          |  persistence:                            |
|    hostPath: /home/username/iom-share  |    local:                                |
|                                        |      hostPath: /home/username/iom-share  |
+----------------------------------------+------------------------------------------+

-----------------
Deprecation Notes
-----------------

Support for *Datadog APM* is deprecated
=======================================

The Usage of *Datadog APM* (Application Performance Monitoring) is deprecated. The according parameter group *datadogApm*
will be removed in a future version of IOM Helm Charts.

-------------
Removal Notes
-------------
          
IOM prior version 4 is not supported any longer
===============================================

IOM Helm charts of version 3.0.0 are only supporting IOM 4 and newer.

Meta-Data were removed from *log*-Settings
==========================================

Helm parameters *log.metaData.tenant* and *log.metaData.environment* were removed from settings.

Passing a *persistent-volume-claim* to be used for shared file-system is not supported any longer
=================================================================================================

Current version of IOM Helm charts does not support any longer to pass the name of an existing
*persistent-volume-claim* to be used for shared file-system.

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
