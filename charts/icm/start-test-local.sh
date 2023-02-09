#!/usr/bin/env bash

set -eu pipefail

source start-test-local_vars.sh

# copy values_iste.tmpl to values.yaml and exchange all declared variables
set +u
eval "echo \"$(< values-test-local.yaml)\"" > values-test-local.tmp
set -u

helm --kubeconfig ${KUBECONFIG} upgrade --install ${HELM_DRY_RUN}${HELM_JOB_NAME} . -f ./values-test-local.tmp
