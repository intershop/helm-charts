+--------------------------+-----------------+--------------------------+
|`< Back                   |`^ Up            |`Next > <Metrics.rst>`_   |
|<SecretKeyRef.rst>`_      |<../README.rst>`_|                          |
+--------------------------+-----------------+--------------------------+

==================
Persistent Storage
==================

--------
Overview
--------

Using *Kubernetes*, the usage of persistent storage is managed on three different levels of abstraction:

- *storage-class*
- *persistent-volume* (*pv*)
- *persistent-volume-claim* (*pvc*)

A *pvc* claims a portion of storage from a *pv*, which is provided by a *storage-class*. *pv* and *storage-class* are
usually provided by administrators, whereas a *pvc* is usually part of the Helm Chart:

- *pvc* -> *pv* -> *storage-class*

One very important aspect of *persistent-volumes* is its handling after deletion of the according Helm release. The behaviour
in this regard is defined by the *reclaim-policy*, which can be controlled on level of *pv* and/or *storage-class*,
but not on level of *pvc*.
There exist two different methods of *reclaim-policy*, *Delete* and *Retain*. In case of *Delete*, a *pv* will be
automatically deleted, when the claiming *pvc* disappears, which is usually the case when the according Helm release
is deleted. If *reclaim-policy* is set to *Retain*, the *pv* will remain along with it's content even after deletion
of the Helm release.

Provisioning of persistent storage
----------------------------------

IOM Helm Charts are supporting three different kinds of provisioning of persistent storage:

- dynamic provisioning
- static provisioning
- local storage

Which kind of provisioning is used by IOM Helm Charts is controlled by parameter *persistence.provisioning*.
Each available method is represented by an according value. The values are *dynamic* (default), *static* and *local*.

Dynamic Provisioning
^^^^^^^^^^^^^^^^^^^^

Dynamic provisioning is the default method to provide persistent storage for IOM, because it's the most easy to use method, which
does not need any interaction with a cluster administrator.
When using this method, the *persistent-volume* is created automatically from the requested *storage-class* (default-value is *azurefile*).
Since the *pv* is created automatically, the *reclaim-policy* cannot be influenced by any Helm parameter. Instead of it,
it is inherited from the *storage-class*.

*azurefile* is the default-value for *persistence.dynamic.storageClass*, which uses *Delete* for *reclaim-policy*. This implies, that the
automatically created *pv* uses *Delete* for *reclaim-policy* too. That means, the usage of default-values of IOM Helm charts could
lead to critical situations on production systems, if the IOM Helm charts would not take further measures.

To avoid the automatic deletion of content of the shared file-system after deletion of IOM Helm release, the default annotation of
the *pvc* is "helm.sh/resource-policy: keep". This annotation prevents the deletion of the *pvc* in case of deletion of IOM Helm release.
As long the *pvc* exists, the *pv* and its content can be saved.

Static Provisioning
^^^^^^^^^^^^^^^^^^^

When using static provisioning, the *persistent-volume* is not created automatically. Instead of it, it has to be provided
by a cluster-administrator. In this case, the cluster-administrator is responsible to configure the *pv* properly.
In difference to dynamic provisioning, there are no default annotations defined for the *pvc*. Hence, the *reclaim-policy*
of the *pv*, which is in responsibility of the cluster-administrator, will always come into effect immediately.

Local Storage
^^^^^^^^^^^^^

The third and last provisioning method for persistent storage is meant for single node test-installations only (e.g. for running IOM
in Docker-Desktop). In difference to the two other provisiong methods, the whole chain of *pvc*, *pv* and *storage-class* is managed
inside the IOM Helm charts. They are created, when the IOM Helm release is created and they will deleted along with the IOM Helm release.
Hence, it's a kind of a simple, care-free method to provide storage for very simple, single node installations.

--------------------------
Recommended Configurations
--------------------------

Dynamic Provisioning
--------------------

Production-Systems and the like
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Use *static provisioning* instead of *dynamic provisioning* for production systems. When using *static provisioning*, there are no problems to reuse
an existing *pv*, even after the deletion of the IOM Helm release. Only if it's not possible to use *static provisioning*, you should
use *dynamic provisioning* of persistent storage. In this case take care of the following two points:
  
- Use a *storage-class* that is using *reclaim-policy* *Retain*. This way it is ensured, that the according *persistent-volume* is
  not deleted automatically after deletion of the IOM Helm release. It is possible to backup the files afterwards or reuse the *pv*
  along with all it's content by a new IOM Helm release (but it's not possible to re-use it, using the same configuration).
- Set *persistence.dynamic.annotations* to an empty value, to create a *pvc* with no annotations at all. Since the *storage-class*
  uses *reclaim-policy* *Retain*, there is no need to keep the according *pvc* alive. With no annotations the *pvc* will be deleted
  automatically, when IOM Helm release is deleted. This will reduce manual operational efforts.

Example:

.. code-block:: yaml

  persistence:
    dynamic:
      storageClass: azurefile-iom
      annotations:

.. note::

  *azurefile-iom* is a *storage-class*, that is provided by *Intershop* within the *Intershop Commerce Platform*,
  that is using *Retain* for *reclaim-policy*.

Test- and Demo-System, without any critical Data
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

- Use a *storage-class* that is using *reclaim-policy* *Delete*. This allows automatic deletion of the *pv*, when the IOM
  Helm release is deleted. A *storage-class* with this property is *azurefile*, which is the default-value.
- Set *persistence.dynamic.annotations* to an empty value, to create a *pvc* with no annotations at all. Since the *storage-class*
  uses *reclaim-policy* *Delete* and there is the intention to delete the *pv* automatically, there is no need to keep the according
  *pvc* alive. With no annotations the *pvc* will be deleted automatically, when IOM Helm release is deleted.

Example:

.. code-block:: yaml

  persistence:
    dynamic:
      annotations:

Static Provisioning
-------------------

Production-Systems and the like
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

*Static provisioning* is the best choice for production systems. If configured properly, which means, the cluster administrator
has to create a *pv* in advance, that is using the right *storage-class* along with *reclaim-policy* *Retain*, this kind
of provisioning of persistent storage is mostly immune against problems. Data stored on persistent storage will not be
deleted, even if the IOM Helm release is deleted. This storage can also be very easily re-used by a new Helm release, without
the need for any changes of Helm parameters.

As drawback, this provisioning method requires initially assistance by a cluster administrator.

Example:

.. code-block:: yaml

  persistence:
   provisioning: static
   static:
     pv: pv-for-iom-xyz
     storageClass: azurefile-iom

Test- and Demo-System, without any critical Data
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

*Static provisioning* of persistent storage is not recommended for this type of systems. If IOM is running in a *real*
Kubernetes cluster, the best choice for this type of system is *dynamic provisioning* of persistent storage.

Local Storage
-------------

Production-Systems and the like
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

NEVER use *Local Storage* for any IOM, that is running in a *real* Kubernetes cluster.


Test- and Demo-System, without any critical Data
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

*Local storage* must be used only in simple, single node implementations of Kubernetes, like *Minikube* or *Docker-Desktop*.
It's recommended to set *persistence.local.hostPath* only.

Example:

.. code-block:: yaml

  persistence:
   provisioning: local
   local:
     hostPath: /home/UserName/iom-share
   
-----------------------------------------------
Reuse a *pv* after Deletion of IOM Helm Release
-----------------------------------------------

There might be the case, that persistent data from shared file-system need to be saved or accessed after deletion of
IOM Helm release. The following examples are showing how this could be done, but they do NOT represent best practice (except for *static provisioning*).
The examples are showing only ONE possible way, how to access a *pv* after deletion of the IOM Helm release. Furthermore
the code snippets are not intended to be copied and executed!


Static Provisioning, configured according the Recommendations for Production Systems
------------------------------------------------------------------------------------

If the *pv* is provided in advance by the cluster administrator and it is using *Retain* for *reclaim-policy*, the according configuration snippet could
look like this:

.. code-block:: yaml

   persistence:
     static:
       pv: pv-for-iom-xyz
       storageClass: azurefile-iom

Using this configuration, an IOM Helm release can be created, deleted and re-created again and again, without any need to adapt the configuration. The content of
the shared file-system will never be deleted and is provided to any re-created IOM Helm release.

But before the *pv* can be re-used, it is necessary to delete the existing *claimRef*. To do so, remove the whole *claimRef*-block from the *pv*.

.. code-block:: shell

  kubectl edit pv pv-for-iom-xyz

  kubectl get pv
  NAME              CAPACITY  ACCESS MODES  RECLAIM POLICY  STATUS     CLAIM                 STORAGECLASS  REASON  AGE
  pv-for-iom-xyz    1Gi       RWX           Retain          Available                        azurefile-iom         19m

The existing *pv* is now *Available* again and can be re-used by a new IOM Helm release.
      
Dynamic Provisioning, configured with default Values
----------------------------------------------------

The default configuration uses *azurefile* for *persistence.dynamic.storageClass*. Since *azurefile* uses *Delete* for *reclaim-policy*,
the default annotation of the *pvc* created by the Helm release is *"helm.sh/resource-policy": keep*, which keeps the *pvc* alive even after
deletion of the IOM Helm release. The existence of the *pvc* then prevents the automatic deletion of the *pv*.

After the deletion of IOM Helm release, *pvc* and *pv* are looking like this. It can be seen, that both are still existing, as if
IOM Helm release would still exist.

.. code-block:: shell

  kubectl get pvc -n test-storage
  NAME      STATUS  VOLUME                                    CAPACITY  ACCESS MODES  STORAGECLASS  AGE
  test-iom  Bound   pvc-873db395-c6c3-4cc5-9ba0-0b56f0f37329  1Gi       RWX           azurefile     48m

  kubectl get pv
  NAME                                      CAPACITY  ACCESS MODES  RECLAIM POLICY  STATUS  CLAIM                  STORAGECLASS  REASON  AGE
  pvc-873db395-c6c3-4cc5-9ba0-0b56f0f37329  1Gi       RWX           Delete          Bound   test-storage/test-iom  azurefile             48m

The first measure is to change the *reclaim-policy* of the *pv* from *Delete* to *Retain*. Otherwise the *pv* would disappear if the *pvc* is
deleted. To do so, the *Kubernetes* object of the *pv* has to be edited. The value of *persistentVolumeReclaimPolicy* has to be changed from
*Delete* to *Retain*.

.. code-block:: shell

  kubectl edit pv pvc-873db395-c6c3-4cc5-9ba0-0b56f0f37329

  kubectl get pv
  NAME                                      CAPACITY  ACCESS MODES  RECLAIM POLICY  STATUS  CLAIM                  STORAGECLASS  REASON  AGE
  pvc-873db395-c6c3-4cc5-9ba0-0b56f0f37329  1Gi       RWX           Retain          Bound   test-storage/test-iom  azurefile             79m

When listing the *pv*, it can be seen, that the *reclaim-policy* has changed to *Retain*. Now the *pvc* can be deleted safely without to
fear the automatic deletion of the *pv*.

.. code-block:: shell
                
  kubectl delete pvc test-iom -n test-storage
  persistentvolumeclaim "test-iom" deleted

  kubectl get pv
  NAME                                      CAPACITY  ACCESS MODES  RECLAIM POLICY  STATUS    CLAIM                  STORAGECLASS  REASON  AGE
  pvc-873db395-c6c3-4cc5-9ba0-0b56f0f37329  1Gi       RWX           Retain          Released  test-storage/test-iom  azurefile             82m

Before the *pv* can be used again, the existing *claimRef* has to be removed. To do so, remove the whole *claimRef*-block from the *pv*.

.. code-block:: shell

  kubectl edit pv pvc-873db395-c6c3-4cc5-9ba0-0b56f0f37329 

  kubectl get pv
  NAME                                      CAPACITY  ACCESS MODES  RECLAIM POLICY  STATUS     CLAIM                 STORAGECLASS  REASON  AGE
  pvc-873db395-c6c3-4cc5-9ba0-0b56f0f37329  1Gi       RWX           Retain          Available                        azurefile             84m

The existing *pv* is now *Available* again and can now be used by a new IOM Helm release. As now an existing *pv* is used, the *static provisioning* method has to be activated.
The according configuration snippet has to look like this. Please note, that additionally to the name of the *pv* also the correct *storage-class* of
the *pv* has to be set.

.. code-block:: yaml
                
  persistence:
    static:
      pv: pvc-873db395-c6c3-4cc5-9ba0-0b56f0f37329
      storageClass: azurefile

Dynamic Provisioning, configured with a *storage-class* using *Retain* for *reclaim-policy*
-------------------------------------------------------------------------------------------

If the *storage-class* uses *Retain* for *reclaim-policy*, the annotations of the *pvc* should be set to allow deletion of the *pvc* along
with the IOM Helm release.

If *storage-class* and *pvc* are configured this way, *pvc* and *pv* are looking like this after deletion of the IOM Helm release. It
can be seen, that the *pvc* is gone and the *pv* still exists.

.. code-block:: shell
                
  kubectl get pvc -n test-storage
  No resources found in test-storage namespace.

  kubectl get pv
  NAME                                      CAPACITY  ACCESS MODES  RECLAIM POLICY  STATUS    CLAIM                  STORAGECLASS   REASON  AGE
  pvc-e9166f21-42de-4682-83d5-4cdae10c18e0  1Gi       RWX           Retain          Released  test-storage/test-iom  azurefile-iom          11m

It can be seen, that the status of the *pv* is *Released*. In order to be able to re-use the *pv*, the *claimRef* has to be removed.
Just remove the whole *claimRef*-block from the *pv*-object:

.. code-block:: shell

  kubectl edit pv pvc-e9166f21-42de-4682-83d5-4cdae10c18e0

  kubectl get pv
  NAME                                      CAPACITY  ACCESS MODES  RECLAIM POLICY  STATUS    CLAIM                  STORAGECLASS   REASON  AGE
  pvc-e9166f21-42de-4682-83d5-4cdae10c18e0  1Gi       RWX           Retain          Available                        azurefile-iom          11m

The existing *pv* can now be used by a new IOM Helm release using the *static provisioning* method. The according configuration snippet has to look like this:

.. code-block:: yaml
                
  persistence:
    static:
      pv: pvc-e9166f21-42de-4682-83d5-4cdae10c18e0
      storageClass: azurefile-iom

+--------------------------+-----------------+--------------------------+
|`< Back                   |`^ Up            |`Next > <Metrics.rst>`_   |
|<SecretKeyRef.rst>`_      |<../README.rst>`_|                          |
+--------------------------+-----------------+--------------------------+
