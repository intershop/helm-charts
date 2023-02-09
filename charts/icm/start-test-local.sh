#!/usr/bin/env bash

set -eu pipefail

source start-test-local_vars.sh

if !(helm plugin list | grep ^set); then
  helm plugin install https://github.com/bery/helm-set.git
fi

helm --kubeconfig ${KUBECONFIG} upgrade --install ${HELM_DRY_RUN}${HELM_JOB_NAME} . -f ./values-iste_linux.tmpl -f ./values-test-local.tmp
