Helm Chart Intershop Commerce Management - ICM
==============================================

This is the ICM helm chart

Prerequisites Details
---------------------

*   helm+kubectl
*   Kubernetes 1.14+

Chart Details
-------------

This chart will do the following:

*   Deploy an ICM Application Server using the `intershop/icm-as` chart
*   Deploy an ICM Web Adapter and Web Adapter Agent using the `intershop/icm-web` chart

Installing the Chart
--------------------

Add the Intershop Helm repository
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Before installing Intershop helm charts, you need to add the `Intershop helm repository <https://intershop.github.io/helm-charts>`_ to your helm client

.. code-block:: bash

    helm repo add intershop https://intershop.github.io/helm-charts
    helm repo update

Install Chart via repository
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

To install the chart with the release name ``icm`` execute

.. code-block:: bash

    helm install my-release intershop/icm --values=values.yaml --namespace icm

Install Chart via cloned helm-charts repo
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    cd charts
    helm dependency update icm
    helm install my-release ./icm --values=values.yaml --namespace icm

Development
-----------

The base development branch for this chart is ``develop/icm``. Before creating a feature/bugfix branch and pull request an issue is need (name shall start with "ICM: <your description>"). If the feature/bugfix branch was taken it might be possible that ``develop/icm`` may change after some time. Then the changes need to be merged into the feature/bugfix branch.
There is a naming convention for feature and bugfix branches like ``feature/icm/<issue number>-<descriptive name>`` or ``bugfix/icm/<issue number>-<descriptive name>``.

Circular dependency
-------------------

There is a circular dependency to the underlying intershop project of this helm chart which manifests itself in having changes, which require also changes in the helm chart. To secure the version compatibility integration tests are done on pull requests before merging into the ``main`` branch.
Some notes on this:

*   the ``appVersion`` in the ``Chart.yaml`` determines the compatible version to the current chart
*   the integration tests need published images on `intershophub <https://hub.docker.com/orgs/intershophub/repositories>`_
*   there might be changes in the underlying project which aren't published via image but chart changes are also required
    *   then either published dev-releases are needed or the feature branch couldn't be merged till an existing published release exists
    *   it's possible to do alpha/beta releases of helm charts, which could be used to test the base changes before publishing any image

Testing the Chart
-----------------

helm-unit
^^^^^^^^^

There are helm-unit tests to support development and secure several functionality.

Prerequisites are:

*   `helm-unittest <https://github.com/helm-unittest/helm-unittest>`_

.. code-block:: bash

    helm unittest --output-file unit.xml --output-type JUnit charts/icm

ct lint & install
^^^^^^^^^^^^^^^^^^

Prerequisites are:

*   `kind cluster <https://github.com/kubernetes-sigs/kind>`_
*   Install cluster: ``kind create cluster --config icm.yaml``

.. code-block:: bash

    docker run -it --network host --workdir=/data --volume <my kube config>:/root/.kube/config:ro --volume
    $(pwd):/data quay.io/helmpack/chart-testing:v3.8.0 ct lint --config ct_icm.yaml

Testing ICM
-----------

This helm chart also allows you to execute intershop htmlunit tests via a testrunner.

Execute locally
^^^^^^^^^^^^^^^

For the local test execution there are already preconfigured values-files orchestrated by a bash script.
Follow these steps to execute a test:

1.  Be sure that each included chart is up-to-date:

    .. code-block:: bash

        helm dependency update ../icm-as
        helm dependency update .

2.  Create needed k8s secrets for icm-web and icm-as (e.g. ``kubectl create secret docker-registry dockerhub --docker-username=<your username> --docker-password=<your password> --docker-email=<your email>``)
3.  run: ``./start-test-local.sh`` and follow the instructions

Local Execution Guide
---------------------

For detailed instructions on local execution, see :doc:`docs/local-execution`.
