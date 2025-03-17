.. Local Execution Guide

.. contents:: Table of Contents
   :depth: 2

📌 Introduction
---------------
This document describes how to run the application locally using the **Helm Chart** and compares this method with execution via the ZIP archive.

✅ Prerequisites
----------------
Before starting, ensure the following are installed:

- **Docker** (with Kubernetes enabled if using Docker Desktop)
- **Helm** (`helm version` should return a valid version)
- **kubectl** (`kubectl version --client` should work)
- **WSL** (if using Linux within Windows)

🔧 Installation and Configuration
---------------------------------

0️⃣ Navigate to the correct directory
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: sh

    cd /path/to/your/project/icm

1️⃣ **Verify Kubernetes Access**
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Run:

.. code-block:: sh

    kubectl cluster-info

If using **Docker Desktop Kubernetes**, ensure WSL can access it:

.. code-block:: sh

    export KUBECONFIG=/mnt/c/Users/<your-username>/.kube/config

Make this change permanent by adding it to `~/.bashrc`:

.. code-block:: sh

    echo 'export KUBECONFIG=/mnt/c/Users/<your-username>/.kube/config' >> ~/.bashrc
    source ~/.bashrc

2️⃣ **Update Helm Dependencies**
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: sh

    helm dependency update ../icm-as
    helm dependency update .

3️⃣ **Verify and Create Kubernetes Secrets**
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: sh

    kubectl get secrets -n icm

If the `icmbuildsnapshot` secret does not exist, create it:

.. code-block:: sh

    kubectl create secret docker-registry icmbuildsnapshot       --docker-server=<registry-url>       --docker-username=<your-username>       --docker-password=<your-password>       --docker-email=<your-email>       --namespace icm

🚀 Run the Local Test
---------------------
Execute the script:

.. code-block:: sh

    bash start-test-local.sh

Follow the displayed instructions.

🔍 Check Pod Status
-------------------

.. code-block:: sh

    kubectl get pods -n icm

If any pods show `Error` or `ImagePullBackOff`, check their logs:

.. code-block:: sh

    kubectl logs -f <pod-name> -n icm

⚠️ Troubleshooting Common Issues
--------------------------------

**Issue: `ImagePullBackOff`**
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

- **Cause:** The Docker image is inaccessible (private or nonexistent).
- **Solution:** Ensure the `icmbuildsnapshot` secret is correctly attached to the pods. Modify `values.yaml` if necessary.

**Issue: `CreateContainerConfigError`**
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

- **Cause:** A missing configuration prevents the container from starting.
- **Solution:** Check the configuration files (`configmaps`, `secrets`) and redeploy with:

.. code-block:: sh

    helm upgrade my-release . --values=values.yaml --namespace icm

**Issue: Kubernetes Unreachable in WSL**
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

- **Cause:** WSL cannot find Docker Desktop Kubernetes.
- **Solution:** Ensure you have run:

.. code-block:: sh

    export KUBECONFIG=/mnt/c/Users/<your-username>/.kube/config

📊 Comparison: Helm Chart vs ZIP
--------------------------------

+---------------------+------------------------------+-----------------+
| **Criteria**        | **Helm Chart**               | **ZIP**         |
+=====================+==============================+=================+
| Installation        | ``helm install``             | Unzip and run a |
|                     |                              | script          |
+---------------------+------------------------------+-----------------+
| Configuration       | ``values.yaml``              | Environment     |
|                     |                              | variables or    |
|                     |                              | local files     |
+---------------------+------------------------------+-----------------+
| Execution           | Kubernetes (pods, services)  | Locally via     |
|                     |                              | a script/Docker |
+---------------------+------------------------------+-----------------+
| Dependencies        | Managed by Kubernetes        | May require     |
|                     |                              | manual          |
|                     |                              | installation    |
+---------------------+------------------------------+-----------------+

📌 Possible Optimizations
-------------------------

- **Detect if Kubernetes is not installed and start a local cluster in a Docker container**.

  - Check if Kubernetes is running:

    .. code-block:: sh

        kubectl cluster-info > /dev/null 2>&1

  - If unavailable, start a lightweight Kubernetes cluster using `kind`:

    .. code-block:: sh

        docker run -d --name kind-control-plane --privileged -p 6443:6443 kindest/node:v1.25.0

  - Extract and use the generated `kubeconfig`:

    .. code-block:: sh

        docker cp kind-control-plane:/etc/kubernetes/admin.conf /tmp/kubeconfig
        export KUBECONFIG=/tmp/kubeconfig
