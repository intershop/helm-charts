#!/usr/bin/env bash

set -xeu pipefail

set -o allexport
source start-test-local_vars.sh
set +o allexport

# puts envs into a comma separated list with dollar signs
env_list=$(env | cut -d '=' -f 1 | sed 's/^/\$/;s/$/,/' | tr -d '\n' | sed 's/,$//')

# now only env variables are replaced in values template
envsubst "${env_list}" < ./values-iste_linux.tmpl | tee values-iste_linux.yaml

helm dependency update .
helm upgrade --install ${HELM_DRY_RUN}${HELM_JOB_NAME} . -f ./values-iste_linux.yaml -f ./values-test-local.yaml
