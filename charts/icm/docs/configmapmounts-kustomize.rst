Using configMapsMounts to mount environment-specific files
==========================================================

This document explains how to manage environment-specific files in a GitOps environments repository and mount them as volumes in the respective deployment.
It is primarily created for Intershop customers and partners and refers to certain Intershop environment-specific functionalities.

.. contents:: Table of Contents
  :depth: 2
  :local:

Prerequisites
-------------
- Access to the GitOps environments repository (e.g., the ``environments`` repository)
- ICM-Helmchart version 2.13.3 or higher (configMapMounts feature requirement)
- The *configMapsMounts* functionality is currently only available for ICM-Web and specifically for the webadapter deployment.
- Install ``kubectl`` for local testing. Follow the instructions at `Install and Set Up kubectl <https://kubernetes.io/docs/tasks/tools/>`_.
**Note**: For more information and additional examples on how to use Kustomize, refer to the `Kustomize Official Documentation <https://kustomize.io/>`_.

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

  apiVersion: kustomize.config.k8s.io/v1beta1
  kind: Kustomization
  namespace: ${namespace}
  configMapGenerator:
  - name: <config-map-name>  # ConfigMap name
    files:
    - ./configs/<file-1> # File to be included in the ConfigMap

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

  apiVersion: kustomize.config.k8s.io/v1beta1
  kind: Kustomization
  namespace: ${namespace}
  ...
  configurations:
    - name-reference-config.yaml

5. Configure ConfigMap Mount in HelmRelease
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
1. Edit the ICM HelmRelease file
2. Add/modify the ``configMapMounts`` section under ``spec/values/icm-web/webadapter``:

.. code-block:: yaml

  apiVersion: helm.toolkit.fluxcd.io/v2beta2
  kind: HelmRelease
  spec:
    values:
    icm-web:
      webadapter:
        configMapMounts:
          - name: <volume-name-key>  # Replace with the volume name
            mountPath: <mount-path>  # Where to mount the file # Result = <mount-path>/<file-1>
            configMapName: <config-map-name>  # Must match kustomization.yaml
            fileName: <file-1>       # Name of the file in the configMap
            fileMode: 440
            readOnly: true

6. Verify the Changes and Behavior
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
1. Use the following command to build the resources and verify the changes:

.. code-block:: bash

  kubectl kustomize <DIRECTORY_OF_KUSTOMIZATION>

2. Check the output to ensure that the ConfigMap and its references are correctly generated.
3. Verify that the `configMapMounts` section in the HelmRelease is properly configured with the expected values.

For more information on the `kubectl kustomize` command, refer to the official Kubernetes documentation at `kubectl documentation <https://kubernetes.io/docs/reference/kubectl/generated/kubectl_kustomize/>`_.

Example
-------
This example shows how to override the default ``robots.txt`` file in the ICM Web Adapter deployment by mounting a custom version from the integration environment.

The original ``robots.txt`` file is provided by the ICM Web Adapter container at ``/intershop/public/robots.txt``. By using configMapMounts, this file can be replaced with an environment-specific version.

Example Folder Structure
^^^^^^^^^^^^^^^^^^^^^^^^
The following structure represents a standard GitOps environments repository provided by *Intershop*.

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

1. Create the custom ``robots.txt`` file in the integration environment:

- Location: ``int/icm/configs/robots.txt``
- This file will override the default ``robots.txt`` in the pod.

2. Configure ConfigMap in ``kustomization.yaml``

.. code-block:: yaml

  apiVersion: kustomize.config.k8s.io/v1beta1
  kind: Kustomization
  namespace: ${namespace}
  configMapGenerator:
  - name: webadapter-overrides
    files:
    - ./configs/robots.txt  # Creates ConfigMap with the custom file
  configurations:
    - name-reference-config.yaml

3. Configure Name Reference in ``name-reference-config.yaml``

.. code-block:: yaml

   nameReference:
   - kind: ConfigMap
     fieldSpecs:
     - path: spec/values/icm-web/webadapter/configMapMounts/configMapName
       kind: HelmRelease

4. Configure configMapMounts in ``int.yaml`` (HelmRelease):

.. code-block:: yaml

  apiVersion: helm.toolkit.fluxcd.io/v2beta2
  kind: HelmRelease
  spec:
    values:
    icm-web:
      webadapter:
        configMapMounts:
        - name: robots-override
          mountPath: /intershop/public  # Target directory in pod
          configMapName: webadapter-overrides
          fileName: robots.txt          # Will replace /intershop/public/robots.txt
          fileMode: 440
          readOnly: true

5. Verify the changes:

- Use the command to build the resources: ``kubectl kustomize int/icm``
- The ConfigMap will have a hash appended to its name (e.g., ``webadapter-overrides-4mtbhkhkfh``). This ensures that any changes to the files in the ConfigMap will result in a new hash, triggering updates in the deployment.
- The ``configMapName`` in the ``configMapMounts`` section of the HelmRelease will automatically reference the ConfigMap with the hash. This is achieved through the ``nameReference`` configuration defined in ``name-reference-config.yaml``.

.. code-block:: yaml

  apiVersion: v1
  data:
    robots.txt: |
     User-agent: *
     Disallow: /private
     # More custom rules can be added here
     # default
  kind: ConfigMap
  metadata:
    name: webadapter-overrides-4mtbhkhkfh
  ---
  apiVersion: helm.toolkit.fluxcd.io/v2beta2
  kind: HelmRelease
  spec:
    values:
     icm-web:
      webadapter:
        configMapMounts:
         - name: robots-override
          mountPath: /intershop/public
          configMapName: webadapter-overrides-4mtbhkhkfh
          fileName: robots.txt
          fileMode: 440
          readOnly: true

Result
^^^^^^
After deployment:

- The original ``/intershop/public/robots.txt`` in the container will be replaced
- The Web Adapter will use the custom ``robots.txt`` from the integration environment
- The file will have permissions set to 440 (read-only)

Additional Information
-----------------------

Binary Files
^^^^^^^^^^^^
In general, binary files should not be stored or maintained in the GitOps environments repository. The following files are typically excluded by default:

- Git files: .git/, .gitignore, .gitmodules, .gitattributes
- File extensions: .jpg, .jpeg, .gif, .png, .wmv, .flv, .tar.gz, .zip
- CI configs: .github/, .circleci/, .travis.yml, .gitlab-ci.yml, appveyor.yml, .drone.yml, cloudbuild.yaml, codeship-services.yml, codeship-steps.yml
- CLI configs: .goreleaser.yml, .sops.yaml
- Flux v1 config: .flux.yaml

If small binary files such as PNG or JPG images need to be used with the ``configMapMounts`` functionality, they should be renamed with a custom extension in the GitOps environments repository, such as ``.png_file`` or ``.jpg_file``. These files can then be renamed back to their original extensions directly in the ``configMapGenerator`` configuration by specifying the desired key name.

**Example:**

1. Add the binary file to the GitOps repository with a custom extension:

- Original file: ``image.png``
- File in repository: ``configs/image.png_file``

2. Update the ``kustomization.yaml`` to include the renamed file and restore its original name:

By specifying the file in the format ``image.png=configs/image.png_file``, you assign the file in the ConfigMap the key ``image.png``. This allows you to reference the file with the desired key name in your application.

.. code-block:: yaml

  configMapGenerator:
  - name: binary-file-config
    files:
      - image.png=configs/image.png_file

3. Configure the HelmRelease to mount the file:

.. code-block:: yaml

  apiVersion: helm.toolkit.fluxcd.io/v2beta2
  kind: HelmRelease
  spec:
    values:
    icm-web:
      webadapter:
        configMapMounts:
        - name: binary-image
          mountPath: /app/images # Target directory in the container
          configMapName: binary-file-config
          fileName: image.png
          fileMode: 440
          readOnly: true


Including Files and Configuration from Outside the GitOps Directory
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Kustomize does not allow including files from outside the current directory. When attempting to build with ``kubectl kustomize <DIRECTORY_OF_KUSTOMIZATION>``, the following error may occur:

``error: security; file '<DIRECTORY_OUTSIDE_OF_KUSTOMIZATION>' is not in or below '<DIRECTORY_OF_KUSTOMIZATION>'``

To resolve this issue, instead of directly including files from the external directory, create a ``kustomization.yaml`` file in the external directory. Configure everything for the external directory in this file, and then reference this ``kustomization.yaml`` as a resource in the main ``kustomization.yaml``.

**Example Folder Structure**

.. code-block:: none

  environments/
  ├── custom_config/                   # Folder for custom configuration
  │   ├── kustomization.yaml           # References all custom config files
  │   ├── robots.txt
  ├── int/                             # Integration environment
  │   ├── icm/                         # ICM product configuration
  │   │   ├── kustomization.yaml       # References all ICM resources
  │   │   ├── int.yaml                 # HelmRelease for ICM
  └── ...

**Example Configuration**

Content of ``custom_config/kustomization.yaml``:

.. code-block:: yaml

  apiVersion: kustomize.config.k8s.io/v1beta1
  kind: Kustomization
  namespace: ${namespace}
  configMapGenerator:
  - name: webadapter-overrides
    files:
    - robots.txt

Content of ``int/icm/kustomization.yaml``:

.. code-block:: yaml

  apiVersion: kustomize.config.k8s.io/v1beta1
  kind: Kustomization
  namespace: ${namespace}
  resources:
  # List of all other resources specific to this environment
  - ../../custom_config  # Include the Kustomization from the custom_config folder

Variable Substitution
^^^^^^^^^^^^^^^^^^^^^

Intershop supports variable substitution to dynamically replace variables in your configuration files. Variables matching the pattern ``${<VariableName>}`` are replaced with their corresponding values during the build process. If no value is defined for a variable, it will default to an empty string.
Intershop creates and maintains these variables to ensure consistency and proper configuration across different environments.

**Example:**

- Input: ``namespace: ${namespace}``
- Substitution: If ``namespace=integration`` is defined, the result will be ``namespace: integration``.

**Escaping Variables:**

To prevent substitution, use the pattern ``$${<VariableName>}``. For example:

- Input: ``$${namespace}``
- Output: ``${namespace}`` (no substitution occurs).

For more details, refer to the `Flux documentation <https://fluxcd.io/flux/components/kustomize/kustomizations/#post-build-variable-substitution>`_.
