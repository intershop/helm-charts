# README for helm unit tests

The files relative to this `README.md` contain test suite/case descriptors that can be executed using a helm plugin called [unittest](https://github.com/quintush/helm-unittest).

## Test structure

Each yaml file contains a test suite as defined by the [unittest]https://github.com/quintush/helm-unittest/blob/master/DOCUMENT.md#test-suite plugin.
The test suites are structured as follows:
* `default-values_test.yaml` just checks if the chart can be rendered using the checked in `values.yaml` (with no custom values set). 
* there's a suite for each aspect (section) of the values 
    * example: `customizations_test.yaml`
* there's a suite for all the _basic_ values (or value that are just passed through) named `basic-config-values_test.yaml`

## Execution

Just execute 

    helm unittest --helm3 .

inside a shell. 

## Plugin installation

Just execute 

    helm plugin install https://github.com/quintush/helm-unittest

inside a shell. 

#### Hint for Windows users

> Execute the command line above using a `git bash` to provide a `/bin/sh` to the plugin's installer (it requires one).

