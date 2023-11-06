+--------------------------+-----------------+--------------------------+
|`< Back                   |`^ Up            |`Next > <Metrics.rst>`_   |
|<SecretKeyRef.rst>`_      |<../README.rst>`_|                          |
+--------------------------+-----------------+--------------------------+

==================
Persistent Storage
==================

IOM Helm Charts are supporting three different kinds of provisioning of persistent storage:

- dynamic provisioning
- static provisioning
- local storage

Which kind of provisioning is used by IOM Helm Charts is controlled by parameter *persistence.provisioning*.
Each available method is represented by an according value. The values are *dynamic* (default), *static* and *local*.

--------
Overview
--------

Using *Kubernetes*, the usage of persistent storage is managed on three different levels of abstraction:

- storage-class
- persistent-volume (pv)
- persistent-volume-claim (pvc)

A *pvc* claims a portion of storage from a *pv*, which is provided by a *storage-class*. *pv* and *storage-class* are
usually provided by administrators, whereas a *pvc* is usually part of the Helm Chart:

- *pvc* -> *pv* -> *storage-class*

One important aspect of *persistent-volumes* and *storage-classes* is the handling of the *pv* after the Helm release is deleted, that
was using a *persistent-volume*. The behaviour can be controlled on level of *pv* and *storage-class*, but not on level of the *pvc*.
It is defined by the *reclaim-policy*, which can be *Delete* or *Retain*. In case of *Delete*, a *pv* is automatically deleted,
when the claiming *pvc* disappears. If the *reclaim-policy* is set to *Retain*, the *pv* will remain along with it's content.

Dynamic Provisioning
--------------------

Dynamic provisioning is the default method to provide persistent storage for IOM, because it's the preferred method in very most cases.
When using this method, the *persistent-volume* is created automatically from the requested *storage-class* (default-value is *azurefile*).
The *reclaim-policy* is defined by the *storage-class*. Since the *pv* is created automatically in case of dynamic provisioning, the
*reclaim-policy* cannot be influenced by any Helm parameter. Instead of it, it is inherited from the *storage-class*.

*azurefile* is the default-value for *persistence.dynamic.storageClass*, which uses *Delete* for *reclaim-policy*. This implies, that the
automatically created *pv* uses *Delete* for *reclaim-policy* too. That means, the usage of default-values of IOM Helm charts could
lead to critical situations on production systems, if the IOM Helm Chart would not take further measures.

To avoid the automatic deletion of content of the shared file-system of IOM after deletion of IOM Helm release, the default annotation of
the *pvc* is "helm.sh/resource-policy: keep". This annotation prevents the deletion of the *pvc* in case of deletion of IOM. As long
the *pvc* exists, the *pv* and its content can be saved.

Static Provisioning
-------------------

When using static provisioning, the *persistent-volume* is not created automatically. Instead of it, it has to be provided
by a cluster-administrator. In this case, the cluster-administrator is responsible to configure the *pv* properly.
In difference to dynamic provisioning, there are no default annotations defined to be used by the *pvc*. Hence, the *reclaim-policy*
of the *pv*, which is in responsibility of the cluster-administrator, will always come into effect immediately.

Local Storage
-------------

The third and last provisioning method for persistent storage is meant for single node test-installations only (e.g. running IOM
in Docker-Desktop). In difference to the two other provisiong methods, the whole chain of *pvc*, *pv* and *storage-class* is managed
inside the IOM Helm charts. They are created, when the IOM Helm release is created and they will deleted along with the IOM Helm release.
Hence, it's a kind of care-free method for very simple, single node installations.

--------------------------
Recommended Configurations
--------------------------

Dynamic Provisioning
--------------------

Production-Systems and the like
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

- Use a *storage-class* that is using *reclaim-policy* "Retain". This way it is ensured, that the according *persistent-volume* is
  not deleted automatically after deletion of the IOM Helm release. It is possible to backup the files afterwards or reuse the *pv*
  with all it's content by a new IOM Helm release.
- Set *persistence.dynamic.annotations* to an empty value, to create a *pvc* with no annotations at all. Since the *storage-class*
  uses *reclaim-policy* "Retain", there is no need to keep the according *pvc* alive. With no annotations the *pvc* will be deleted automatically,
  when IOM Helm release is deleted. This will reduce operational efforts.

Example:

.. code-block:: yaml

  persistence:
    dynamic:
      storageClass: azurefile-iom
      annotations:

.. note::

  *azurefile-iom* is a *storage-class*, that is provided by *Intershop* within the *Intershop Commerce Platform*,
  that is using "Retain* for *reclaim-policy*.

Test- and Demo-System, without any critical Data
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

- Use a *storage-class* that is using *reclaim-policy* "Delete". This allows automatic deletion of the *pv*, when the IOM
  Helm release is deleted. A *storage-class* with this property is *azurefile*, which is the default-value.
- Set *persistence.dynamic.annotations* to an empty value, to create a *pvc* with no annotations at all. Since the *storage-class*
  uses *reclaim-policy* "Delete" and we have the intention to delete the *pv* automatically, there is no need to keep the according
  *pvc* alive. With no annotations the *pvc* will be deleted automatically, when IOM Helm release is deleted.

Example:

.. code-block:: yaml

  persistence:
    dynamic:
      annotations:

-----------------------------------------------
Reuse a *pv* after Deletion of IOM Helm Release
-----------------------------------------------

Dynamic Provisioning
--------------------

System, configured with default Values
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The default configuration uses *azurefile* for *persistence.dynamic.storageClass*. Since *azurefile* uses "Delete" for *reclaim-policy*,
the default annotation of the *pvc* created by the Helm release is *"helm.sh/resource-policy": keep*, which keeps alive the *pvc* even after
deletion of the IOM Helm release. The existence of the *pvc* then prevents the automatic deletion of the *pv*.

.. note::

   The following code fragments are from a real example. They are not intended to be copied and executed!

After the deletion of IOM Helm release, *pvc* and *pv* are looking like this. It can be seen, that both are still existing, as if
IOM Helm release would still exist.

.. code-block:: shell

  kubectl get pvc -n test-storage
  NAME      STATUS  VOLUME                                    CAPACITY  ACCESS MODES  STORAGECLASS  AGE
  test-iom  Bound   pvc-873db395-c6c3-4cc5-9ba0-0b56f0f37329  1Gi       RWX           azurefile     48m

  kubectl get pv
  NAME                                      CAPACITY  ACCESS MODES  RECLAIM POLICY  STATUS  CLAIM                  STORAGECLASS  REASON  AGE
  pvc-873db395-c6c3-4cc5-9ba0-0b56f0f37329  1Gi       RWX           Delete          Bound   test-storage/test-iom  azurefile             48m

The first measure is to change the *reclaim-policy* of the *pv* from "Delete" to "Retain". Otherwise the *pv* would disappear if the *pvc* is
deleted. To do so, the *Kubernetes* object of the *pv* has to be edited. The value of *persistentVolumeReclaimPolicy* has to be changed from
*Delete* to *Retain*.

.. code-block:: shell

  kubectl edit pv pvc-873db395-c6c3-4cc5-9ba0-0b56f0f37329

  kubectl get pv
  NAME                                      CAPACITY  ACCESS MODES  RECLAIM POLICY  STATUS  CLAIM                  STORAGECLASS  REASON  AGE
  pvc-873db395-c6c3-4cc5-9ba0-0b56f0f37329  1Gi       RWX           Retain          Bound   test-storage/test-iom  azurefile             79m

Now the *pvc* can be deleted safely without to fear the automatic deletion of the *pv*.

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

The existing *pv* can now be used by a new IOM Helm release using the *static provisioning* method. The according configuration snippet has to look like this:

.. code-block:: yaml
                
  persistence:
    static:
      pv: pvc-873db395-c6c3-4cc5-9ba0-0b56f0f37329
      storageClass: azurefile

System, configured according recomendations for Production-Systems
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Just to recapitulate: the *storage-class* to be used has to use *Retain* for *reclaim-policy*. In this case the *pvc* will be deleted
along with the IOM Helm release. In order to work this way, parameter *persistence.dynamic.annotations* has to be set to an empty value.

.. note::

   The following code fragments are from a real example. They are not intended to be copied and executed!

After the deletion of IOM Helm release, *pvc* and *pv* are looking like this. It can be seen, that the *pvc* is gone and the
*pv* still exists.

.. code-block:: shell
                
  kubectl get pvc -n test-storage
  No resources found in test-storage namespace.

  kubectl get pv
  NAME                                      CAPACITY  ACCESS MODES  RECLAIM POLICY  STATUS    CLAIM                  STORAGECLASS   REASON  AGE
  pvc-e9166f21-42de-4682-83d5-4cdae10c18e0  1Gi       RWX           Retain          Released  test-storage/test-iom  azurefile-iom          11m

It can be seen, that the status of the *pv* is *Released*. In order to be able to reuse the *pv*, the *claimRef* has to be removed.
Just remove the whole *claimRef*-block from the object:

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
