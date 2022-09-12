+--------------------------+-----------------+--------------------------+
|`< Back                   |`^ Up            |`Next > <Postgresql.rst>`_|
|<SecretKeyRef.rst>`_      |<../README.rst>`_|                          |
+--------------------------+-----------------+--------------------------+

================================================
Helm Charts for Intershop Order Management (IOM)
================================================

------------------
Prometheus Metrics
------------------

IOM provides an HTTP endpoint */metrics* at port 9990, that delivers a huge amount of metrics. These metrics are provided in `Prometheus <https://prometheus.io>`_
format, which is a widely used format, that can be understood by mostly all monitoring systems.

The metrics are provided by the *Wildfly* sub-system *microprofile-metrics-smallrye*. The according
`Quickstart guide <https://github.com/wildfly/quickstart/blob/main/microprofile-metrics/README.adoc#accessing-the-metrics>`_
provides more information and also how to access the metrics directly at the HTTP endpoint.


Example of Integration with *Datadog*
=====================================

`Datadog <https://www.datadoghq.com>`_ is a monitoring system. The following example will demonstrate how to use the *IOM Helm Charts*
to integrate IOM metrics with *Datadog*

The *Datadog* documentation about `Kubernetes Integration by Autodiscovery <https://docs.datadoghq.com/containers/kubernetes/integrations/?tab=kubernetesadv1#>`_
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

In case of integration with IOM, the placeholder *<CONTAINER_IDENTIFIER>* has to be replaced always by *iom* (when using IOM version >= 4).

According to *Datadogs* `Documentation about Prometheus and Openmetrics integration <https://docs.datadoghq.com/containers/kubernetes/prometheus/?tab=kubernetesadv1>`_, the placeholder *<INTEGRATION_NAME>* has to be replaced by *"openmetrics"*.

The same document states, that *<INIT_CONFIG>* has to be replaced by *{}*.

Finally the *<INSTANCE_CONFIG>* has to be replaced by a structure of the tree elements: *openmetrics_endpoint*, *namespace* and *metrics*. Please refer `Documentation about Prometheus and Openmetrics integration <https://docs.datadoghq.com/containers/kubernetes/prometheus/?tab=kubernetesadv1>`_ for a detailed description of this configuration.

The example above can now be translated into according Helm values to be used by *IOM Helm Charts*. Please note the following remarks.

- *<CONTAINER_IDENTIFIER>* was replaced by *iom*. This value is fix and must not be changed.
- *<INTEGRATION_NAME>* was replaced by *"openmetrics"*. This value is fix and must not be changed.
- *<INIT_CONFIG>* was replaced by *{}*. This value is fix and must not be changed.
- *<INSTANCE_CONFIG>* was replaced by *{ "openmetrics_endpoint": "http://%%host%%:9990/metrics", "namespace": "iom.appserver", "metrics": [ "application_*", "base_gc_*" ]}*.

  - *"openmetrics_endpoint": "http://%%host%%:9990/metrics"* is fix and must not be changed.
  - *"namespace": "iom.appserver"* is an example only. The value *iom.appserver* will be used as prefix, when showing the metrics in *Datadog*.
  - *"metrics": [ "application_\*", "base_gc_\*" ]* is an example only. This configuration selects the metrics to be shown in *Datadog*. The current configuration is
    showing all metrics, that are beginning with *application_* and *base_gc_*. In fact, at the time of writing, IOM provides more than 20.000 metrics. You have to
    select in which ones you are interessted in. To get the full list of available metrics, please see
    `Quickstart guide of microprofile-metrics-smallrye <https://github.com/wildfly/quickstart/blob/main/microprofile-metrics/README.adoc#accessing-the-metrics>`_
    how to get the complete list.

.. code-block:: yaml

  # Example of yaml code to be inserted into the values file of *IOM Helm Charts*.
  podAnnotations:
    ad.datadoghq.com/iom.check_names: '["openmetrics"]'
    ad.datadoghq.com/iom.init_configs: '[{}]'
    ad.datadoghq.com/iom.instances: |
        [
          {
            "openmetrics_endpoint": "http://%%host%%:9990/metrics",
            "namespace": "iom.appserver",
            "metrics": [ "application_*", "base_gc_*" ]
          }
        ]

+--------------------------+-----------------+--------------------------+
|`< Back                   |`^ Up            |`Next > <Postgresql.rst>`_|
|<SecretKeyRef.rst>`_      |<../README.rst>`_|                          |
+--------------------------+-----------------+--------------------------+
