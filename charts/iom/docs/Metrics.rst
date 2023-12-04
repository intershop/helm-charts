+--------------------------+-----------------+--------------------------+
|`< Back                   |`^ Up            |`Next > <Postgresql.rst>`_|
|<PersistentStorage.rst>`_ |<../README.rst>`_|                          |
+--------------------------+-----------------+--------------------------+

================================================
Helm Charts for Intershop Order Management (IOM)
================================================

------------------
Prometheus Metrics
------------------

IOM version 4.2.0 and later provides an HTTP endpoint */metrics* at port 9990 that delivers a huge amount of metrics. These metrics are
provided in `Prometheus <https://prometheus.io>`_ format, which is a widely used format that can be understood by most
monitoring systems.

Example of Integration with *New Relic / OpenTelemetry*
=======================================================

The combination of `New Relic <https://newrelic.com>`_ and `OpenTelemetry Collector <https://opentelemetry.io>`_ is used by *Intershop Commerce Platform* to collect and report *Prometheus metrics*. The following example shows how to configure Helm parameters to integrate IOM metrics with *New Relic / OpenTelemetry*.

*OpenTelemetry Collector* gets the information about the endpoint, providing the metrics, from annotations made to the pods. The according Helm parameters have to look like this, to enable the *OpenTelemetry Collector* to receive data from IOM:

.. code-block:: yaml

  podAnnotations:
    prometheus.io/scrape: 'true'
    prometheus.io/path: '/metrics'
    prometheus.io/port: '9990'  

Example of Integration with *Datadog*
=====================================

`Datadog <https://www.datadoghq.com>`_ is a monitoring system. The following example will demonstrate how to use the *IOM Helm Charts*
to integrate IOM metrics with *Datadog*.

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

In case of integration with IOM, the placeholder *<CONTAINER_IDENTIFIER>* has to be always replaced with *iom*.

According to *Datadogs* `Documentation about Prometheus and Openmetrics integration <https://docs.datadoghq.com/containers/kubernetes/prometheus/?tab=kubernetesadv1>`_, the placeholder *<INTEGRATION_NAME>* has to be replaced with *"openmetrics"*.

The same document states that *<INIT_CONFIG>* needs to be *{}*.

Finally *<INSTANCE_CONFIG>* has to be replaced by a structure of the tree elements: *openmetrics_endpoint*, *namespace* and *metrics*. Please refer to `Documentation about Prometheus and Openmetrics integration <https://docs.datadoghq.com/containers/kubernetes/prometheus/?tab=kubernetesadv1>`_ for a detailed description of this configuration.

The example above can be translated into according Helm values to be used by *IOM Helm Charts*. Please note the following remarks.

- *<CONTAINER_IDENTIFIER>* was replaced with *iom*. This value is fixed and must not be changed.
- *<INTEGRATION_NAME>* was replaced with *"openmetrics"*. This value is fixed and must not be changed.
- *<INIT_CONFIG>* was replaced with *{}*. This value is fixed and must not be changed.
- *<INSTANCE_CONFIG>* was replaced with *{ "openmetrics_endpoint": "http://%%host%%:9990/metrics", "namespace": "iom.appserver", "metrics": [ "application_\*", "base_gc_\*" ]}*.

  - *"openmetrics_endpoint": "http://%%host%%:9990/metrics"* is fixed and must not be changed.
  - *"namespace": "iom.appserver"* is an example only. The value *iom.appserver* will be used as prefix when showing the metrics in *Datadog*.
  - *"metrics": [ "application_\*", "base_gc_\*" ]* is an example only. This configuration selects the metrics to be shown in *Datadog*. The current configuration
    shows all metrics beginning with *application_* and *base_gc_*. In fact, at the time of writing IOM provides more than 20.000 metrics. You can
    select the metrics that you are interested in. To get the full list of available metrics, see
    `Quickstart guide of microprofile-metrics-smallrye <https://github.com/wildfly/quickstart/blob/main/microprofile-metrics/README.adoc#accessing-the-metrics>`_
    how to get the complete list.

Below is the example from *Datadog* documentation translated into Helm values suitable for *IOM Helm Charts*. For
further usage of this piece of yaml-code, the values of *namespace* and *metrics* have to be adapted according to the requirements.

.. code-block:: yaml

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
|<PersistentStorage.rst>`_ |<../README.rst>`_|                          |
+--------------------------+-----------------+--------------------------+
