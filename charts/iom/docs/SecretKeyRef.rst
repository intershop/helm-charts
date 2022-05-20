References to Kubernetes Secrets
********************************

All parameters ending by *SecretKeyRef* serve as an alternative way to provide secret information. Instead of storing entries as plain text in the values file, these parameters allow reference entries within Kubernetes secrets. For more information about secrets, see `public Kubernetes documentation <https://kubernetes.io/docs/concepts/configuration/secret/>`_.

*SecretKeyRef* parameters require a hash structure, consisting of two entries with the following hash-keys:

* name: is the name of the Kubernetes secret, containing the referenced key
* key: is the name of the entry within the secret
  
The following two boxes show an example which consists of two parts:

* The definition of the Kubernetes secret, which contains entries for different secret values, and
* The values file, which references these values.
  
Example: Kubernetes secret
==========================

.. code-block:: yaml
		
  apiVersion: v1
  kind: Secret
  metadata:
    name: pgsecrets
  type: Opaque
  data:
    pguser:   cG9zdGdyZXM=
    pgpasswd: ZGJ1c2VycGFzc3dk


Example: values file
====================

.. code-block:: yaml
		
  ...
  # general postgres settings, required to connect to postgres server
  # and root db.
  pg:
    userSecretKeyRef:
      name: pgsecrets
      key:  pguser
    passwdSecretKeyRef:
      name: pgsecrets
      key:  pgpasswd
    db:                 postgres
    sslMode:            prefer
    sslCompression:     "1"
    sslRootCert:
  ...
