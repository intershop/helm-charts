================================================
Helm Charts for Intershop Order Management (IOM)
================================================

The following documents provide an extensive documentation how to operate IOM with IOM Helm Charts:

1.  `Tools & Concepts <docs/ToolsAndConcepts.rst>`_
2.  `Example: local Demo running in Docker-Desktop <docs/ExampleDemo.rst>`_
3.  `Example: Production System in AKS <docs/ExampleProd.rst>`_
4.  `Helm parameters of IOM <docs/ParametersIOM.rst>`_
5.  `Helm parameters of Integrated SMTP server <docs/ParametersMailhog.rst>`_
6.  `Helm parameters of Integrated NGINX Ingress Controller <docs/ParametersNGINX.rst>`_
7.  `Helm parameters of Integrated PostgreSQL Server <docs/ParametersPosgres.rst>`_
8.  `Helm parameters of IOM-Tests <docs/ParametersTests.rst>`_
9.  `References to Kubernetes Secrets <docs/SecretKeyRef.rst>`_
10. `PostgreSQL Server Configuration <docs/Postgresql.rst>`_
11. `Options and Requirements of IOM Database <docs/IOMDatabase.rst>`_

======================
Dependency Information
======================

=============
Version 2.2.0
=============

------------
New Features
------------

New Parameter *podDisruptionBudget.maxUnavailable* has been added
=================================================================

*PodDisruptionBudget* has been added to IOM Helm Charts. *PodDisruptionBudgets* define the behavior of pods during a
voluntary disruption of the Kubernetes Cluster. The default value of parameter *podDisruptionBudget.maxUnavailable*
is 1, which guarantees that only one IOM pod will be unavailable during a voluntary disruption of the Kubernetes cluster.

See also `Helm parameters of IOM <docs/ParametersIOM.rst>`_.

New Parameter-Group *podAntiAffinity* has been added
====================================================

Parameter-group *podAntiAffinity* along with the according default values, prevents scheduling of more than one IOM
pod of current helm release onto one node. This way the IOM deployment becomes robuts againts failures of a single node.

See also `Helm parameters of IOM <docs/ParametersIOM.rst>`_.

New Parameter-Group *spreadPods* has been added
===============================================

*spreadPods* provides an alternative or additional method to spread IOM pods over nodes. In difference to *podAntiAffinity*
it is possible to run more than one pod per node. E.g. if there are 2 nodes and 4 pods the pods are evenly spread over the
nodes. Each node is then running 2 pods. Additionally it is very easy to combine different topologies.

In difference to *podAntiAffinity*, *spreadPods* is disabled on default.

See also `Helm parameters of IOM <docs/ParametersIOM.rst>`_.

---------------
Migration Notes
---------------

*podAntiAffinity* is enabled and uses *mode: required* on default
=================================================================

*podAntiAffinity* is enabled and uses *mode: required* on default, which makes the IOM deployment instantly more robust against
failures of a single node. Each IOM pod requires it's own node in this case. But, if the according Kubernetes cluster does not provide
the required number of nodes, the deployment of IOM will fail.

Please check your cluster in advance. If the capacity is not sufficient, please use *podAntiAffinity.mode: preferred* instead.

-------------
Fixed Defects
-------------



