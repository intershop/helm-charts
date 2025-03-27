Using configMapsMounts to mount environment-specific files
==========================================================

This document explains how to manage environment-specific files in a GitOps environments repository and mount them as volumes in the respective deployment.

Prerequisites
-------------
- Access to the GitOps environments repository (e.g., the ``environments`` repository)
- ICM-Helmchart version 2.13.3 or higher (configMapMounts feature requirement)

Note: The **configMapsMounts** functionality is currently only available for ICM-Web and specifically for the webadapter deployment.

Step-by-Step Guide
-----------------

1. Create Files in the Environment
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
1. Navigate to the product environment directory.
2. Create a ``configs`` directory.
3. Place all files that should override deployment data in this directory.

2. Configure ConfigMap Generator
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
1. Edit the ``kustomization.yaml`` file in the environment directory.
2. Add or modify the ``configMapGenerator`` section:

.. code-block:: yaml

   configMapGenerator:
   - name: <config-map-name>  # ConfigMap name
     files:
     - ./configs/<file-1>  # List all files to include
     # Add additional files as needed

3. Create Name Reference Configuration File
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
1. Create ``name-reference-config.yaml``
2. Add the following content:

.. code-block:: yaml

   # Configures how Kustomize handles name references for ConfigMaps
   nameReference:
   - kind: ConfigMap
     fieldSpecs:
     - path: spec/values/icm-web/webadapter/configMapMounts/configMapName
       kind: HelmRelease

4. Configure Kustomization with Name Reference
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
1. Edit ``kustomization.yaml`` again.
2. Add the configuration reference:

.. code-block:: yaml

   configurations:
     - name-reference-config.yaml

5. Configure ConfigMap Mount in HelmRelease
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
1. Edit the ICM HelmRelease file
2. Add/modify the ``configMapMounts`` section under ``spec/values/icm-web/webadapter``:

.. code-block:: yaml

   configMapMounts:
     - name: <volume-name-key>  # Replace with the volume name
       mountPath: <mount-path>  # Where to mount the file
       configMapName: <config-map-name>  # Must match kustomization.yaml
       fileName: <file-1>       # Name of the file in the configMap
       fileMode: 440
       readOnly: true


Example
-------
This example shows how to override the default ``robots.txt`` file in the ICM Web Adapter deployment by mounting a custom version from the integration environment.

The original ``robots.txt`` file is provided by the ICM Web Adapter container at ``/intershop/public/robots.txt``. By using configMapMounts, this file can be replaced with an environment-specific version.

Example Folder Structure
^^^^^^^^^^^^^^^^^^^^^^^^
The following structure represents a standard setup provided by *Intershop*.

.. code-block:: none

   environments/
   ├── int/                   # Integration environment
   │   ├── icm/               # ICM product configuration
   │   │   ├── kustomization.yaml  # References all ICM resources
   │   │   ├── int.yaml            # HelmRelease for ICM
   │   └── pwa/               # PWA product configuration
   │       └── ...            # Similar structure
   ├── uat/                   # UAT environment
   └── ...

Implementation Steps
^^^^^^^^^^^^^^^^^^^^
1. Create the custom ``robots.txt`` in the integration environment:

- Location: ``/int/icm/configs/robots.txt``
- This file will override the default one in the pod

2. Configure in ``kustomization.yaml``:

.. code-block:: yaml

   configMapGenerator:
   - name: webadapter-overrides
     files:
     - ./configs/robots.txt  # Creates ConfigMap with the custom file

   configurations:
     - name-reference-config.yaml

3. Configure name reference handling:

.. code-block:: yaml

   # name-reference-config.yaml
   nameReference:
   - kind: ConfigMap
     fieldSpecs:
     - path: spec/values/icm-web/webadapter/configMapMounts/configMapName
       kind: HelmRelease

4. Mount the ConfigMap in HelmRelease:

.. code-block:: yaml

   # int.yaml (HelmRelease)
   configMapMounts:
     - name: robots-override
       mountPath: /intershop/public  # Target directory in pod
       configMapName: webadapter-overrides
       fileName: robots.txt          # Will replace /intershop/public/robots.txt
       fileMode: 440
       readOnly: true

Result
^^^^^^
After deployment:

- The original ``/intershop/public/robots.txt`` in the container will be replaced
- The Web Adapter will use the custom ``robots.txt`` from the integration environment
- The file will have permissions set to 440 (read-only)
