Replication Configuration
=========================

This document describes the configuration options for the **replication** feature in the `icm` Helm Chart.

The replication settings are used to define whether the ICM-AS instance is part of a replication setup (e.g., staging-to-live scenarios) and how source and target systems are configured.

Configuration Options
---------------------

All settings are configured within the `replication` block in your `values.yaml`.

.. code-block:: yaml

   replication:
     enabled: false
     role: <source|target>                  # Deprecated
     targetSystemUrl: <externalUrl>         # Deprecated
     sourceDatabaseName: <databaseName>     # Deprecated
     source:
       webserverUrl: <sourceExternalUrl>
       databaseLink: <sourceDatabaseLink>
       databaseUser: <sourceDatabaseUser>
       databaseName: <sourceDatabaseName>
     targets:
       live1:
         webserverUrl: <targetExternalUrl>
         databaseUser: <targetDatabaseUser>
       live2:
         webserverUrl: <targetExternalUrl>
         databaseUser: <targetDatabaseUser>

Options Description
-------------------

**enabled**
   *Type:* `boolean`
   Enables or disables replication support. Set to `true` if this ICM-AS instance is part of a replication system.

Deprecated Options
------------------

**role**
   *Type:* `string` (`source` | `target`)
   Defines the role of this system within the replication setup.
   **Deprecated since Helm Charts 2.2.0**. Use `source` and `target` instead.

**targetSystemUrl**
   *Type:* `string`
   **Deprecated since Helm Charts 2.2.0**. Use `targets` instead.

**sourceDatabaseName**
   *Type:* `string`
   **Deprecated since Helm Charts 2.2.0**. Use `source.databaseName` instead.

Source Configuration
--------------------

If `role` is set to `source`, configure the following block:

**source.webserverUrl**
   *Type:* `string`
   External URL of the source system (e.g., via ingress/proxy).

**source.databaseLink**
   *Type:* `string`
   The database link to the source database.
   *Note:* Either `databaseLink` **or** `databaseName` must be configured. `databaseName` should be preferred for performance reasons.

**source.databaseUser**
   *Type:* `string`
   The database user for accessing the source system.

**source.databaseName**
   *Type:* `string`
   The name of the source database schema.

Targets Configuration
---------------------

Define one or more target systems:

**targets.<name>.webserverUrl**
   *Type:* `string`
   External URL of the target system.

**targets.<name>.databaseUser**
   *Type:* `string`
   The database user that will be granted access to the source database schema.

Preferred Example Configuration
---------------------

.. code-block:: yaml

   replication:
     enabled: true
     source:
       webserverUrl: https://icm-domain-edit
       databaseName: src_db_name
       databaseUser: src_db_user
     targets:
       live1:
         webserverUrl: https://icm-domain-live1
         databaseUser: tgt_db_user1
       live2:
         webserverUrl: https://icm-domain-live2
         databaseUser: tgt_db_user2

Notes
-----

- Avoid using characters like `.`, `-`, or `_` in target system names.
- The `source` and `targets` blocks take precedence over deprecated properties.
- Deprecated properties will be removed in a future version.
- `replication.source.databaseName` should be preferred over `replication.source.databaseLink` because of performance reasons
- `replication.source.webserverUrl` should use the intershop domain with ssl (through ingress) to avoid issues with the replication process.
  Nethertheless, if `http` is configured, a automatic redirect to `https` will be done.

