#!/usr/bin/env bash

set -eu pipefail

set -o allexport
source start-test-local_vars.sh
read -e -p 'Helm chart name: ' -i 'icm-11-replication-test' HELM_JOB_NAME
read -e -p 'Testsuite: ' -i 'tests.remote.com.intershop.product.suite.ProductMassDataReplicationTestSuite' TESTSUITE
read -e -p 'Test image: ' -i 'intershophub/icm-as-test:11.2.0' ICM_TEST_IMAGE
read -e -p 'Base path of your local folder mount: ' -i '/run/desktop/mnt/host/d/tmp/pv' LOCAL_MOUNT_BASE
read -e -p 'The pull secret for the icm-as+testrunner image (e.g. dockerhub or icmbuildsnapshot): ' -i 'dockerhub' ICM_AS_PULL_SECRET
read -e -p 'The pull secret for the icm-wa+waa image: ' -i 'dockerhub' ICM_WEB_PULL_SECRET
set +o allexport

# puts envs into a comma separated list with dollar signs
env_list=$(env | cut -d '=' -f 1 | sed 's/^PATH$//' | sed 's/^/\$/;s/$/,/' | tr -d '\n' | sed 's/,$//')

# now only env variables are replaced in values template
envsubst "${env_list}" < ./values-iste_linux.tmpl | tee values-iste_linux.yaml

envsubst "${env_list}" < ./values-test-local.tmpl | tee values-test-local.yaml

helm dependency update ../icm-as # wait for https://github.com/helm/helm/issues/2247
helm dependency update ../icm
helm dependency update .
helm upgrade --install ${HELM_DRY_RUN}${HELM_JOB_NAME} . -f ./values-iste_linux.yaml -f ./values-test-local.yaml
