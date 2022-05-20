.. topic:: Navigation

  `< Back <Postgres.rst>`_ | `^ Up <../README.rst>`_ | 


Options and Requirements of IOM Database
****************************************

Tablespace
==========

The database initialization made by dbaccount image is creating a user and database, which uses the system-wide default tablespace *pg_default*. If you want to use a custom tablespace, you have to create it prior to the database initialization, see `PostgreSQL: Documentation: 12: CREATE TABLESPACE <https://www.postgresql.org/docs/12/static/sql-createtablespace.html>`_.

To make the database initialization process aware of this newly created tablespace, the parameter *dbaccount.tablespace* has to be set to its name. If this is done, this tablespace will be set as default tablespace for the IOM database user and for the IOM database during the initialization process.

Timezone
========

All database clients and the IOM database have to use the same timezone. For this reason, all IOM Docker images are configured on OS-level to use timezone Etc/UTC. The process, executed by dbaccount init-image, sets this timezone for the IOM database user as well.

Locale/Encoding
===============

The locale of database clients and the locale of the IOM database have to be identical. For this reason, all IOM Docker images are setting environment variable ``LANG`` to ``en_US.utf8``.

Accordingly, the setting on the database is made by dbaccount init-image. Using parameter *dbaccount.options*, it is possible to configure this process.

When creating the IOM database by dbaccount init-image, using the wrong Encoding, Collate or Ctype is the most common reason for failed initialization of the IOM database. The according values have to be exactly identical to the values used by template databases. Hence, if there are any problems with Encoding, Collate, or Ctype when creating the IOM database, the existing databases should be listed to get the correct values. To do so, use *psql* database client with parameter ``-l`` to list them.

The following box shows how to do this after an initialization error if IOM is running on Docker-Desktop.

.. code-block::

  # get name of PostgreSQL pod
  kubectl get pods -n iom
  NAME                                             READY   STATUS       RESTARTS   AGE
  demo-ingress-nginx-controller-6c6f5b88cc-6wsfh   1/1     Running      0          67s
  demo-iom-0                                       0/1     Init:Error   3          67s
  demo-mailhog-5d7677c7c5-zl8gl                    1/1     Running      0          67s
  demo-postgres-96676f4b-mt8nl                     1/1     Running      0          67s
 
  # execute psql -U postgres -l within PostgreSQL pod
  kubectl exec demo-postgres-96676f4b-mt8nl -n iom -t -- psql -U postgres -l
                                 List of databases
     Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges
  -----------+----------+----------+------------+------------+-----------------------
   postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 |
   template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
             |          |          |            |            | postgres=CTc/postgres
   template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
             |          |          |            |            | postgres=CTc/postgres
  (3 rows)

Search-Path
===========

In some circumstances, the search path for database objects has to be extended. Search-Path is set by dbaccount init-image. This process can be configured by parameter *dbaccount.searchPath*.

.. topic:: Navigation

  `< Back <Postgres.rst>`_ | `^ Up <../README.rst>`_ | 
