+--------------------------+-----------------+--------------------------+
|`< Back                   |`^ Up            |`Next > <Postgresql.rst>`_|
|<SecretKeyRef.rst>`_      |<../README.rst>`_|                          |
+--------------------------+-----------------+--------------------------+

================================================
Helm Charts for Intershop Order Management (IOM)
================================================

-------
Metrics
-------

IOM provides an HTTP endpoint */metrics* at port 9990, that delivers a huge amount of metrics. These metrics are provided in `Prometheus <https://prometheus.io>`_
format, which is a widely used format, that can be understood by mostly all monitoring systems.

The metrics are provided by the *Wildfly* sub-system *microprofile-metrics-smallrye*. The according
`Quickstart guide <https://github.com/wildfly/quickstart/blob/main/microprofile-metrics/README.adoc#accessing-the-metrics>`_
provides information how to access the metrics directly at the HTTP endpoint.

--------------------------
Integration into *Datadog*
--------------------------

`Datadog <https://www.datadoghq.com>`_ is a monitoring system. The following example will demonstrate how to use the *IOM Helm Charts*
to integrate IOM metrics into *Datadog*

The *Datadog* documentation about Kubernetes Integration by Autodiscovery <https://docs.datadoghq.com/containers/kubernetes/integrations/?tab=kubernetesadv1#>`_
shows the following example:

.. code-block:: yaml

  apiVersion: v1
  kind: Pod
  # (...)
  metadata:
    name: '<POD_NAME>'
    annotations:
      ad.datadoghq.com/<CONTAINER_IDENTIFIER>.check_names: '[<INTEGRATION_NAME>]'
      ad.datadoghq.com/<CONTAINER_IDENTIFIER>.init_configs: '[<INIT_CONFIG>]'
      ad.datadoghq.com/<CONTAINER_IDENTIFIER>.instances: '[<INSTANCE_CONFIG>]'
      # (...)
  spec:
    containers:
      - name: '<CONTAINER_IDENTIFIER>'
  # (...)

The *<CONTAINER_IDENTIFIER>* will always be *iom*, when using IOM version >= 4.

According to *Datadogs* `Documentation about Prometheus and Openmetrics integration <https://docs.datadoghq.com/containers/kubernetes/prometheus/?tab=kubernetesadv1>`_, the placeholder *<INTEGRATION_NAME>* has to be replaced by *"openmetrics"*.

This document states, that *<INIT_CONFIG>* has to be replaced by *{}*.

Finally the *<INSTANCE_CONFIG>* has to be replaced by a structure of the tree elements *openmetrics_endpoint*, *namespace* and *metrics*. Please refer `Documentation about Prometheus and Openmetrics integration <https://docs.datadoghq.com/containers/kubernetes/prometheus/?tab=kubernetesadv1>`_ for a detailed description of these elements.

The example above can now be translated into according Helm values to be used by *IOM Helm Charts*. Please note, that

- *<CONTAINER_IDENTIFIER>* was replaced by *iom*,
- *<INTEGRATION_NAME>* was replaced by *"openmetrics"*,
- *<INIT_CONFIG>* was replaced by *{}* and
- *<INSTANCE_CONFIG>* was replaced by *{ "openmetrics_endpoint": "http://%%host%%:9990/metrics", "namespace": "iom.appserver", "metrics": [ "application" ]}*

.. code-block:: yaml

  podAnnotations:
    ad.datadoghq.com/iom.check_names: '[<INTEGRATION_NAME>]'
    ad.datadoghq.com/iom.init_configs: '[<INIT_CONFIG>]'
    ad.datadoghq.com/iom.instances: '[<INSTANCE_CONFIG>]'

+--------------------------+-----------------+--------------------------+
|`< Back                   |`^ Up            |`Next > <Postgresql.rst>`_|
|<SecretKeyRef.rst>`_      |<../README.rst>`_|                          |
+--------------------------+-----------------+--------------------------+
