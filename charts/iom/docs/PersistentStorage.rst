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

One important aspect of *persistent-volumes* and *storage-classes* is the behaviour after the application, that
was using a *persistent-volume*, has gone and with it the according *persistent-volume-claim*. The behaviour can be
controlled on level of *pv* and *storage-class*, but not on level of the *pvc*. It is defined by the *retain-policy*,
which can be *delete* or *reclaim*. In case of *delete*, a *pv* is automatically deleted, when the claiming *pvc*
disappears. If the *retain-policy* is set to *reclaim*, the *pv* will remain along with it's content.

--------------------
dynamic provisioning
--------------------

Dynamic provisioning is the default method to provide persistent storage for IOM, because it's the preferred method in very most cases.
When using this method, the *persistent-volume* is created automatically from the requested *storage-class* (default is *azurefile*).
The *retain-policy* is defined by the *storage-class*. Since the *pv* is created automatically, the *retain-policy* cannot be
influenced by any Helm parameter. Instead of it, it is inherited from the *storage-class*.

Since the default *storage-class* "azurefile" uses the *reclaim-policy* "delete", the usage of default values could lead to critical
situations on production systems, if the Helm Chart would not take further measures. To avoid the automatic deletion of content of the shared
file-system of IOM after deletion of the IOM instance, the default annotation of the *pvc* is "helm.sh/resource-policy: keep".
This annotation prevents the deletion of the *pvc* in case of deletion of IOM. As long the *pvc* exists, the *pv* and its
content can be saved.

Recommended Configurations
--------------------------

Produktions- und produktionsnahe Systeme:
* Verwenden einer StorageClass mit RetainPolicy "reclaim"
* annotations überschreiben, so dass '"helm.sh/resource-policy": keep' nicht angewendet wird
* Beispiel:

Test- und Demo-Systeme ohne kritische Daten:
* Verwenden einer StorageClass mit RetainPolicy "delete", z.B. azurefiles
* annotations überschreiben, so dass '"helm.sh/resource-policy": keep' nicht angewendet wird
* Beispiel:

Wiederverwenden von Daten nach versehentlichem Löschen
----------------------------------------------

PV mit ReclaimPolicy retain:
* nicht beschrieben, das ist der Standardfall -> Suche im Internet

PV mit ReclaimPolicy delete, aber nicht gelöschtem PVC:
muss ich ausprobieren

-------------------
static provisioning
-------------------

Anstatt, dass das PersistentVolume automatisch (dynamisch) angelegt wird, kann ein existierendes PV benutzt werden,
welches zuvor durch einen Clusteradministrator angelegt wurde.
In diesem Fall ist der Clusteradministrator dafür verantwortlich, für die richtige Konfiguration des PV zu sorgen.
Im Gegensatz zum "dynamic provisioning" wird das PVC ohne jegliche Annotions angelegt, so dass die RetainPolicy
des PV sofort zum Tragen kommt.

-------------
local storage
-------------

Nutzung nur für lokale (nicht verteilte) Installationen, z.B. in Docker-Desktop.
Was sind die Eigenschaften?
* lokale StorageClass wird angelegt
* Reclaim-Policy ist Retain (PV bleibt bestehen)

+--------------------------+-----------------+--------------------------+
|`< Back                   |`^ Up            |`Next > <Metrics.rst>`_   |
|<SecretKeyRef.rst>`_      |<../README.rst>`_|                          |
+--------------------------+-----------------+--------------------------+
