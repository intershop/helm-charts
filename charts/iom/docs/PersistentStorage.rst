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

A *pvc* claims a portion of storage from a *pv* that is provided by a *storage-class*. *pv* and *storage-class* are
usually provided by administrators, while a *pvc* is usually part of the Helm Chart:

- *pvc* -> *pv* -> *storage-class*

One very important aspect of *persistent-volumes* is the handling after deletion of the according Helm release. The behavior
in this regard is defined by the *reclaim-policy*, which can be controlled at *pv* and/or *storage-class* level,
but not at *pvc* level.
There are two different methods of *reclaim-policy*, *Delete* and *Retain*. In case of *Delete*, a *pv* will be
automatically deleted when the claiming *pvc* disappears, which is usually the case when the corresponding Helm release
is deleted. If *reclaim-policy* is set to *Retain*, the *pv* will remain along with its content even after deletion
of the Helm release.

Provisioning of Persistent Storage
==================================

IOM Helm Charts support three different kinds of provisioning of persistent storage:

- Dynamic provisioning
- Static provisioning
- Local storage

The type of provisioning used by IOM Helm Charts is controlled by the parameters *persistence.provisioning* and
*postgres.persistence.provisioning*.
Each available method is represented by a corresponding value. The values are *dynamic* (default), *static* and *local*.

Dynamic Provisioning
--------------------

Dynamic provisioning is the default method to provide persistent storage, because it is the easiest to use method that does not require 
interaction with a cluster administrator.
When using this method, the *persistent-volume* (*pv*) is created automatically from the requested *storage-class* (default-value is *azurefile*).
Since the *pv* is created automatically, the *reclaim-policy* cannot be influenced by any Helm parameter. Instead,
it is inherited from the *storage-class*.

*azurefile* is the default-value for *persistence.dynamic.storageClass*, which uses *Delete* for *reclaim-policy*. This implies that the
automatically created *pv* uses *Delete* for *reclaim-policy* too. This means that using the default values of the IOM Helm charts could 
lead to critical situations on production systems if the IOM Helm charts do not take further action.

To avoid the automatic deletion of content of the shared file system after deletion of IOM Helm release, the default annotation of
the *pvc* is "helm.sh/resource-policy: keep". This annotation prevents the *pvc* from being deleted when the IOM Helm release is deleted.
As long the *pvc* exists, the *pv* and its content can be saved.

Static Provisioning
-------------------

When using static provisioning, the *persistent-volume* is not created automatically. Instead, it has to be provided
by a cluster administrator. In this case, the cluster administrator is responsible for properly configuring the *pv*.
In contrast to dynamic provisioning, there are no default annotations defined for the *pvc*. Hence, the *reclaim-policy*
of the *pv*, which is the responsibility of the cluster administrator, will always take effect immediately.

Local Storage
-------------

The third and last provisioning method for persistent storage is meant for single node test-installations only (for example, for running IOM
in Docker-Desktop). In contrast to the two other provisioning methods, the whole chain of *pvc*, *pv* and *storage-class* is managed
within the IOM Helm charts. They are created when the IOM Helm release is created and they will be deleted along with the IOM Helm release.
It is therefore simple, carefree method to provide storage for very simple, single node installations.

When running IOM on *Unix*-like system, like *Linux*, *Mac OS X*, etc., the usage of the according parameter *persistence.local.hostPath*
is straight forward. Just set the name of the directory to be used for persistent storage.

When using *Windows* to run IOM, it is more complicated. Intershop recommends to use *WSL 2* in this case. When using *WSL 2*, the path to be
set on *persistence.local.hostPath* has to be *Unix*-style. To get the right format, use ``pwd`` to print out the name of the directory to
be used for persistent storage. Additionally, the path has to be prefixed with ``/run/desktop/mnt/host``.

Example for *Windows* + *WSL 2*:

When using ``C:\Users\username\iom-share`` for the shared file system, running ``pwd`` within this directory
will deliver ``/c/Users/username/iom-share``. Together with the prefix ``/run/desktop/mnt/host`` a valid configuration
for a *Windows* system with *WSL 2* has to look like this:

.. code-block:: yaml

  persistence:
    provisioning: local
    local:
      hostPath: /run/desktop/mnt/host/c/Users/username/iom-share

Recommended Configurations for the Shared File System
=====================================================

Dynamic Provisioning
--------------------

Production Systems
^^^^^^^^^^^^^^^^^^

Use *static provisioning* instead of *dynamic provisioning* for production systems. When using *static provisioning*, there are no problems to reuse
an existing *pv*, even after the deletion of the IOM Helm release. Only if it is not possible to use *static provisioning*, you should
use *dynamic provisioning* of persistent storage. In this case, take care of the following two points:
  
- Use a *storage-class* that uses *reclaim-policy* *Retain*. This way, it is ensured that the according *persistent-volume* is
  not deleted automatically after deletion of the IOM Helm release. It is possible to back up the files afterwards or reuse the *pv*
  along with all its content by a new IOM Helm release. However, it is not possible to reuse it with the same configuration.
- Set *persistence.dynamic.annotations* to an empty value to create a *pvc* with no annotations at all. Since the *storage-class*
  uses *reclaim-policy* *Retain*, there is no need to keep the according *pvc* alive. With no annotations, the *pvc* will be deleted
  automatically when the IOM Helm release is deleted. This will reduce manual operational efforts.

Example:

.. code-block:: yaml

  persistence:
    dynamic:
      storageClass: azurefile-iom
      annotations:

.. regular note is not properly rendered by GitHub      

**Note**   

  *azurefile-iom* is a *storage-class*, that is provided by *Intershop* within the *Intershop Commerce Platform*,
  which uses *Retain* for *reclaim-policy*.

Test and demo system, without any critical Data


- Use a *storage-class* that uses *reclaim-policy* *Delete*. This allows for the automatic deletion of the *pv* when the IOM Helm 
  release is deleted. A *storage-class* with this property is *azurefile*, which is the default-value.
- Set *persistence.dynamic.annotations* to an empty value to create a *pvc* with no annotations at all. Since the *storage-class*
  uses *reclaim-policy* *Delete* and there is the intention to delete the *pv* automatically, there is no need to keep the according
  *pvc* alive. With no annotations, the *pvc* will be deleted automatically when the IOM Helm release is deleted.

Example:

.. code-block:: yaml

  persistence:
    dynamic:
      annotations:

Static Provisioning
-------------------

Production Systems
^^^^^^^^^^^^^^^^^^

*Static provisioning* is the best choice for production systems. If configured properly, which means that the cluster 
administrator must create a *pv* in advance, i.e. using the correct *storage-class* along with the *reclaim-policy* *Retain*, this type
of persistent storage provisioning is mostly immune to problems. Data stored on persistent storage will not be
deleted, even if the IOM Helm release is deleted. This storage can also be easily reused by a new Helm release without
any changes to the Helm parameters.

As a drawback, this provisioning method requires initial assistance from a cluster administrator.

Example:

.. code-block:: yaml

  persistence:
    provisioning: static
    static:
      pv: pv-for-iom-xyz
      storageClass: azurefile-iom

Test and demo system, without any critical data:

*Static provisioning* of persistent storage is not recommended for this type of systems. If IOM is running in a *real*
Kubernetes cluster, the best choice for this type of system is *dynamic provisioning* of persistent storage.

Local Storage
-------------

Production Systems
^^^^^^^^^^^^^^^^^^

NEVER use *Local Storage* for any IOM that is running in a *real* Kubernetes cluster.


Test and Demo System, Without Any Critical Data
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

*Local storage* must be used only in simple, single node implementations of Kubernetes, like *Minikube* or *Docker-Desktop*.
Intershop recommends to set *persistence.local.hostPath* only.

Example:

.. code-block:: yaml

  persistence:
    provisioning: local
    local:
      hostPath: /home/UserName/iom-share
   
Reuse a *pv* After Deletion of IOM Helm Release
===============================================

For some examples that show the reuse of a *pv* after the IOM Helm release has been deleted, please see the following `document <PersistentStorageExamplesReusePV.rst>`_.

+--------------------------+-----------------+--------------------------+
|`< Back                   |`^ Up            |`Next > <Metrics.rst>`_   |
|<SecretKeyRef.rst>`_      |<../README.rst>`_|                          |
+--------------------------+-----------------+--------------------------+
