Integrated NGINX Ingress Controller
***********************************

A complete list of parameters can be found here: https://github.com/kubernetes/ingress-nginx/tree/master/charts/ingress-nginx

The table below only lists parameters that have to be changed for different operation options of IOM and those that must not be changed at all.

+----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|Parameter                               |Description                                                                                    |Default Value                                 |
|                                        |                                                                                               |                                              |
+========================================+===============================================================================================+==============================================+
|nginx.enabled                           |Controls whether an integrated NGINX ingress controller should be installed or not. This       |false                                         |
|                                        |ingress controller can serve two purposes:                                                     |                                              |
|                                        |                                                                                               |                                              |
|                                        |* It can be used instead of the cluster-wide ingress controller. This should be done only if no|                                              |
|                                        |  cluster-wide ingress controller exists. This is typically the case ofvery simple Kubernetes  |                                              |
|                                        |  environments like Docker Desktop, Minikube, etc. The example `Local Demo System running in   |                                              |
|                                        |  Docker-Desktop on Mac OS X <TODO>`_ shows this kind of usage.                                |                                              |
|                                        |                                                                                               |                                              |
|                                        |* It can be used as a proxy between the cluster-wide ingress controller and IOM if the         |                                              |
|                                        |  cluster-wide ingress controller is not an NGINX. IOM requires sticky sessions, which has to  |                                              |
|                                        |  be realized by the ingress controller. Since this feature is only available when using an    |                                              |
|                                        |  NGINX ingress controller, it has to be realized by the integrated NGINX ingress controller if|                                              |
|                                        |  the cluster-wide one is of another kind, see `Sticky sessions <TODO>`_.                      |                                              |
+----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|nginx.proxy.enabled                     |Controls if the integrated NGINX ingress controller should act as a proxy between cluster-wide |true                                          |
|                                        |ingress controller and IOM, or as an ingress controller used instead of the cluster-wide one.  |                                              |
|                                        |                                                                                               |                                              |
+----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|nginx.proxy.annotations                 |Annotations for the ingress.                                                                   |{}                                            |
|                                        |                                                                                               |                                              |
|                                        |* Ignored, if *nginx.proxy.enabled* is set to *false*.                                         |                                              |
+----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|ingress-nginx.controller.replicaCount   |Desired number of controller pods.                                                             |2                                             |
|                                        |                                                                                               |                                              |
|                                        |                                                                                               |                                              |
+----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|ingress-nginx.controller.service.type   |Type of controller service to create.                                                          |ClusterIP                                     |
|                                        |                                                                                               |                                              |
|                                        |When using the integrated NGINX controller as a proxy, *ClusterIP* is the right choice, since  |                                              |
|                                        |the proxy must not be publicly accessible. If it should be used instead of the cluster-wide    |                                              |
|                                        |ingress controller, it has to be publicly accessible. In this case                             |                                              |
|                                        |*ingress-nginx.controller.service.type* has to be set to *LoadBalancer*. See example `Local    |                                              |
|                                        |Demo System running in Docker-Desktop on Mac OS X <TODO>`_.                                    |                                              |
+----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|ingress-nginx.controller.extraArgs      |Additional command line arguments to pass to nginx-ingress-controller.                         |                                              |
|                                        |                                                                                               |                                              |
|                                        |Example to increase verbosity: ``{ v: 3 }``                                                    |                                              |
+----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|ingress-nginx.controller.config         |Adds custom configuration options to Nginx, see `ingress-nginx user-guide                      |.. code-block:: json                          |
|                                        |<https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap/>`_.      |                                              |
|                                        |                                                                                               |  { use-forwarded-headers: "true",            |
|                                        |                                                                                               |  proxy-add-original-uri-header: "true" }     |
+----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|ingress-nginx.rbac.create               |If *true*, create & use RBAC resources.                                                        |true                                          |
|                                        |                                                                                               |                                              |
|                                        |* Must not be changed.                                                                         |                                              |
+----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|ingress-nginx.rbac.scope                |If *true*, do not create & use clusterrole and -binding. Set to *true* in combination with     |true                                          |
|                                        |*controller.scope.enabled=true* to disable load-balancer status updates and scope the ingress  |                                              |
|                                        |entirely.                                                                                      |                                              |
|                                        |                                                                                               |                                              |
|                                        |* Must not be changed.                                                                         |                                              |
+----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|ingress-nginx.controller.ingressClass   |Name of the ingress class to route through this controller.                                    |nginx-iom                                     |
|                                        |                                                                                               |                                              |
|                                        |* Must not be changed.                                                                         |                                              |
+----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
|nginx-ingress.controller.scope.enabled  |Limit the scope of the ingress controller. If set to *true*, only the release namespace is     |true                                          |
|                                        |watched for ingress.                                                                           |                                              |
|                                        |                                                                                               |                                              |
|                                        |* Must not be changed.                                                                         |                                              |
+----------------------------------------+-----------------------------------------------------------------------------------------------+----------------------------------------------+
