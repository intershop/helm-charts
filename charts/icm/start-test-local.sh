#!/usr/bin/env bash

set -eu pipefail

source start-test-local_vars.sh

# copy values_iste.tmpl to values.yaml and exchange all declared variables
set +u
eval "echo \"$(< values-iste_linux.tmpl)\"" > values-test-local.tmp
set -u

helm --kubeconfig ${KUBECONFIG} install ${HELM_DRY_RUN}${HELM_JOB_NAME} . -f ./values-test-local.tmp -f ./values-test-local.yaml
