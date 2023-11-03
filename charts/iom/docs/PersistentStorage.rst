+--------------------------+-----------------+--------------------------+
|`< Back                   |`^ Up            |`Next > <Metrics.rst>`_   |
|<SecretKeyRef.rst>`_      |<../README.rst>`_|                          |
+--------------------------+-----------------+--------------------------+

==================
Persistent Storage
==================

Unterstützung von 3 Arten von Persistent Storage:
* dynamic provisioning
* static provisioning
* local storage

Priorität ist umgekehrt.
Wenn "local storage" konfiguriert ist, werden static and dynamic provisioning ignoriert.
Wenn "static provisioning" konfiguriert ist, wird dynamic provisioning ignoriert.

--------------------
dynamic provisioning
--------------------

In den allermeisten Installationen ist dies die bevorzugte Nutzung von persistent storage.
PersistentVolume is created automatically from StorageClass (default: azurefile) with requested size (default: 1Gi).
Die RetainPolicy (also das Verhalten des PersistentVolume nachdem es nicht mehr benutzt wird) wird durch die StorageClass
festgelegt und kann nicht über die Helm-Values beeinflusst werden. Z.B. ist die ReclaimPolicy für azurefile "delete", d.h.
das dynamisch erzeugte PersistentVolume würde in diesem Fall automatisch gelöscht werden.

In kritischen Produktionsumgebungen könnte dieses Verhalten dazu führen, dass wichtige Daten aus Versehen gelöscht werden.
Um das zu verhindern, sollte eine StorageClass verwendet werden, die die ReclaimPolicy "retain" benutzt. Um aber vollkommen
auf der sicheren Seite zu sein, auch im Fall, dass eine StorageClass mit ReclaimPolicy "delete" verwendet wird, besitzt die
von den IOM Helm Charts erzeugte PVC per default die Annotation '"helm.sh/resource-policy": keep'. Damit bleibt auch nach dem
Löschen der Helm Release von IOM der PVC erhalten und das PV wird nicht gelöscht.

Empfehlungen zur Konfiguration
------------------------------

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
