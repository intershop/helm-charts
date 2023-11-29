+-------------------------+
|`^ Up                    |
|<PersistentStorage.rst>`_|
+-------------------------+

================================================
Helm Charts for Intershop Order Management (IOM)
================================================

-----------------------------------------------
Reuse a *pv* after Deletion of IOM Helm Release
-----------------------------------------------

There might be the case, that persistent data from shared file-system need to be saved or accessed after deletion of
IOM Helm release. The following examples are showing how this could be done, but they do NOT represent best practice (except for *static provisioning*).
The examples are showing only ONE possible way, how to access a *pv* after deletion of the IOM Helm release. Furthermore
the code snippets are not intended to be copied and executed!

Static Provisioning, configured according the Recommendations for Production Systems
====================================================================================

If the *pv* is provided in advance by the cluster administrator and it is using *Retain* for *reclaim-policy*, the according configuration snippet could
look like this:

.. code-block:: yaml

   persistence:
     provisioning: static
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
====================================================

The default configuration uses *azurefile* for *persistence.dynamic.storageClass*. Storage-class *azurefile* uses *Delete* for *reclaim-policy*.
Default annotation of the *pvc* created by the Helm release is *"helm.sh/resource-policy": keep*, which keeps the *pvc* alive even after
deletion of the IOM Helm release. The existence of the *pvc* then prevents the automatic deletion of the *pv*.

After the deletion of the IOM Helm release, *pvc* and *pv* are looking like this. It can be seen, that both are still existing, as if
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
    provisioning: static
    static:
      pv: pvc-873db395-c6c3-4cc5-9ba0-0b56f0f37329
      storageClass: azurefile

Dynamic Provisioning, configured with a *storage-class* using *Retain* for *reclaim-policy*
===========================================================================================

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
    provisioning: static
    static:
      pv: pvc-e9166f21-42de-4682-83d5-4cdae10c18e0
      storageClass: azurefile-iom

+-------------------------+
|`^ Up                    |
|<PersistentStorage.rst>`_|
+-------------------------+
