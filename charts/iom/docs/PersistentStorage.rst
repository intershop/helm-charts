+--------------------------+-----------------+--------------------------+
|`< Back                   |`^ Up            |`Next > <Metrics.rst>`_   |
|<SecretKeyRef.rst>`_      |<../README.rst>`_|                          |
+--------------------------+-----------------+--------------------------+

================================================
Helm Charts for Intershop Order Management (IOM)
================================================

------------------
Persistent Storage
------------------

Overview
========

Using *Kubernetes*, the usage of persistent storage is managed at three different levels of abstraction:

- *storage-class*
- *persistent-volume* (*pv*)
- *persistent-volume-claim* (*pvc*)

A *pvc* claims a portion of storage from a *pv*, which is provided by a *storage-class*. *pv* and *storage-class* are
usually provided by administrators, whereas a *pvc* is usually part of the Helm Chart:

- *pvc* -> *pv* -> *storage-class*

One very important aspect of *persistent-volumes* is its handling after deletion of the according Helm release. The behaviour
in this regard is defined by the *reclaim-policy*, which can be controlled at level of *pv* and/or *storage-class*,
but not at level of *pvc*.
There exist two different methods of *reclaim-policy*, *Delete* and *Retain*. In case of *Delete*, a *pv* will be
automatically deleted, when the claiming *pvc* disappears, which is usually the case when the according Helm release
is deleted. If *reclaim-policy* is set to *Retain*, the *pv* will remain along with its content even after deletion
of the Helm release.

Provisioning of persistent storage
==================================

IOM Helm Charts are supporting three different kinds of provisioning of persistent storage:

- dynamic provisioning
- static provisioning
- local storage

Which kind of provisioning is used by IOM Helm Charts is controlled by parameter *persistence.provisioning*.
Each available method is represented by an according value. The values are *dynamic* (default), *static* and *local*.

Dynamic Provisioning
--------------------

Dynamic provisioning is the default method to provide persistent storage for IOM, because it's the easiest to use method, which
does not need any interaction with a cluster administrator.
When using this method, the *persistent-volume* (*pv*) is created automatically from the requested *storage-class* (default-value is *azurefile*).
Since the *pv* is created automatically, the *reclaim-policy* cannot be influenced by any Helm parameter. Instead of it,
it is inherited from the *storage-class*.

*azurefile* is the default-value for *persistence.dynamic.storageClass*, which uses *Delete* for *reclaim-policy*. This implies that the
automatically created *pv* uses *Delete* for *reclaim-policy* too. That means, the usage of default-values of IOM Helm charts could
lead to critical situations on production systems, if the IOM Helm charts did not take further measures.

To avoid the automatic deletion of content of the Shared File System after deletion of IOM Helm release, the default annotation of
the *pvc* is "helm.sh/resource-policy: keep". This annotation prevents the deletion of the *pvc* in case of deletion of IOM Helm release.
As long the *pvc* exists, the *pv* and its content can be saved.

Static Provisioning
-------------------

When using static provisioning, the *persistent-volume* is not created automatically. Instead of that, it has to be provided
by a cluster-administrator. In this case, the cluster-administrator is responsible for configure the *pv* properly.
In difference to dynamic provisioning, there are no default annotations defined for the *pvc*. Hence, the *reclaim-policy*
of the *pv*, which is in responsibility of the cluster-administrator, will always come into effect immediately.

Local Storage
-------------

The third and last provisioning method for persistent storage is meant for single node test-installations only (e.g. for running IOM
in Docker-Desktop). In difference to the two other provisioning methods, the whole chain of *pvc*, *pv* and *storage-class* is managed
inside the IOM Helm charts. They are created when the IOM Helm release is created and they will be deleted along with the IOM Helm release.
Hence, it is a kind of a simple, care-free method to provide storage for very simple, single node installations.

Recommended Configurations
==========================

Dynamic Provisioning
--------------------

Production-Systems
^^^^^^^^^^^^^^^^^^

Use *static provisioning* instead of *dynamic provisioning* for production systems. When using *static provisioning*, there are no problems to reuse
an existing *pv*, even after the deletion of the IOM Helm release. Only if it is not possible to use *static provisioning*, you should
use *dynamic provisioning* of persistent storage. In this case, take care of the following two points:
  
- Use a *storage-class* that is using *reclaim-policy* *Retain*. This way, it is ensured that the according *persistent-volume* is
  not deleted automatically after deletion of the IOM Helm release. It is possible to back up the files afterwards or reuse the *pv*
  along with all its content by a new IOM Helm release (but it is not possible to re-use it, using the same configuration).
- Set *persistence.dynamic.annotations* to an empty value, to create a *pvc* with no annotations at all. Since the *storage-class*
  uses *reclaim-policy* *Retain*, there is no need to keep the according *pvc* alive. With no annotations, the *pvc* will be deleted
  automatically, when the IOM Helm release is deleted. This will reduce manual operational efforts.

Example:

.. code-block:: yaml

  persistence:
    dynamic:
      storageClass: azurefile-iom
      annotations:

.. note::

  *azurefile-iom* is a *storage-class*, that is provided by *Intershop* within the *Intershop Commerce Platform*,
  which is using *Retain* for *reclaim-policy*.

Test- and Demo-System, without any critical Data


- Use a *storage-class* that is using *reclaim-policy* *Delete*. This allows automatic deletion of the *pv* when the IOM
  Helm release is deleted. A *storage-class* with this property is *azurefile*, which is the default-value.
- Set *persistence.dynamic.annotations* to an empty value, to create a *pvc* with no annotations at all. Since the *storage-class*
  uses *reclaim-policy* *Delete* and there is the intention to delete the *pv* automatically, there is no need to keep the according
  *pvc* alive. With no annotations, the *pvc* will be deleted automatically when the IOM Helm release is deleted.

Example:

.. code-block:: yaml

  persistence:
    dynamic:
      annotations:

Static Provisioning
-------------------

Production-Systems
^^^^^^^^^^^^^^^^^^

*Static provisioning* is the best choice for production systems. If configured properly, which means the cluster administrator
has to create a *pv* in advance, that is, using the right *storage-class* along with *reclaim-policy* *Retain*, this kind
of provisioning of persistent storage is mostly immune against problems. Data stored on persistent storage will not be
deleted, even if the IOM Helm release is deleted. This storage can also be very easily re-used by a new Helm release, without
the need for any changes to Helm parameters.

As a drawback, this provisioning method requires initial assistance from a cluster administrator.

Example:

.. code-block:: yaml

  persistence:
    provisioning: static
    static:
      pv: pv-for-iom-xyz
      storageClass: azurefile-iom

Test- and Demo-System, without any critical Data


*Static provisioning* of persistent storage is not recommended for this type of systems. If IOM is running in a *real*
Kubernetes cluster, the best choice for this type of system is *dynamic provisioning* of persistent storage.

Local Storage
-------------

Production-Systems
^^^^^^^^^^^^^^^^^^

NEVER use *Local Storage* for any IOM that is running in a *real* Kubernetes cluster.


Test- and Demo-System, without any critical Data
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

*Local storage* must be used only in simple, single node implementations of Kubernetes, like *Minikube* or *Docker-Desktop*.
It is recommended to set *persistence.local.hostPath* only.

Example:

.. code-block:: yaml

  persistence:
    provisioning: local
    local:
      hostPath: /home/UserName/iom-share
   
Reuse a *pv* after Deletion of IOM Helm Release
===============================================

For a couple of examples, showing the re-use of a *pv* after deletion of the IOM Helm release, please see the following `document <PersistentStorageExamplesReusePV.rst>`_.

+--------------------------+-----------------+--------------------------+
|`< Back                   |`^ Up            |`Next > <Metrics.rst>`_   |
|<SecretKeyRef.rst>`_      |<../README.rst>`_|                          |
+--------------------------+-----------------+--------------------------+
