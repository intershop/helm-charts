#!/usr/bin/env bash

set -eu pipefail

set -o allexport
source start-test-local_vars.sh
read -e -p 'Helm chart name: ' -i 'icm-11-azure-test2' HELM_JOB_NAME

DEFAULT_TESTSUITE='tests.remote.com.intershop.cms.suite.PageListingTestSuite'
TESTSUITE="${TESTSUITE:-$DEFAULT_TESTSUITE}"
read -e -p 'Testsuite: ' -i "$TESTSUITE" TESTSUITE || { echo "Error reading input"; exit 1; }

DEFAULT_ICM_TEST_IMAGE='intershophub/icm-as-test:11.9.0'
ICM_TEST_IMAGE="${ICM_TEST_IMAGE:-$DEFAULT_ICM_TEST_IMAGE}"
read -e -p 'Test image: ' -i "$ICM_TEST_IMAGE" ICM_TEST_IMAGE || { echo "Error reading input"; exit 1; }

read -e -p 'The pull secret for the icm-as+testrunner image (e.g. dockerhub or icmbuildsnapshot): ' -i 'icmbuildsnapshot' ICM_AS_PULL_SECRET
read -e -p 'The pull secret for the icm-proxy image: ' -i 'dockerhub' ICM_WEB_PULL_SECRET
set +o allexport

# puts envs into a comma separated list with dollar signs
env_list=$(env | cut -d '=' -f 1 | sed 's/^PATH$//' | sed 's/^/\$/;s/$/,/' | tr -d '\n' | sed 's/,$//')

# now only env variables are replaced in values template
envsubst "${env_list}" < ./values-iste_linux.tmpl | tee values-iste_linux.yaml

envsubst "${env_list}" < ./values-test-azure.tmpl | tee values-test-azure.yaml

# start test
helm dependency update ../icm-as # wait for https://github.com/helm/helm/issues/2247
helm dependency update .
helm upgrade --install ${HELM_DRY_RUN} ${HELM_JOB_NAME} . -f ./values-iste_linux.yaml -f ./values-test-azure.yaml
