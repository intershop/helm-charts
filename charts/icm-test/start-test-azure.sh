#!/usr/bin/env bash

set -eu pipefail

set -o allexport
source ./scripts/start-test-local_vars.sh

# check Kubernetes secrets
source ./scripts/check-kubernetes-secrets.sh

read -e -p 'Helm chart name: ' -i 'icm-11-azure-test' HELM_JOB_NAME

DEFAULT_TESTSUITE='tests.remote.com.intershop.cms.suite.PageListingTestSuite'
TESTSUITE="${TESTSUITE:-$DEFAULT_TESTSUITE}"
read -e -p 'Testsuite: ' -i "$TESTSUITE" TESTSUITE || { echo "Error reading input"; exit 1; }

DEFAULT_ICM_TEST_IMAGE='intershophub/icm-as-test:11.9.0'
ICM_TEST_IMAGE="${ICM_TEST_IMAGE:-$DEFAULT_ICM_TEST_IMAGE}"
read -e -p 'Test image: ' -i "$ICM_TEST_IMAGE" ICM_TEST_IMAGE || { echo "Error reading input"; exit 1; }

read -e -p 'The pull secret for the icm-as+testrunner image: ' -i 'dockerhub' ICM_AS_PULL_SECRET
read -e -p 'The pull secret for the icm-proxy image: ' -i 'dockerhub' ICM_WEB_PULL_SECRET
set +o allexport

read -e -p 'Do you already have an Azure storage account configured with the necessary data? (y/n) ' -i 'n' HAS_AZURE_STORAGE_ACCOUNT

if [[ "$HAS_AZURE_STORAGE_ACCOUNT" == 'y' ]]; then
    read -e -p 'The Azure resource group of your storage account: ' -i 'ateam-common' AZURE_RESOURCE_GROUP
    read -e -p 'The Azure storage account name: ' -i 'testisteazurestorage' AZURE_STORAGE_ACCOUNT
else
    echo "Since no azure storage account was configured yet, a new one will be created now..."
    read -e -p 'Base path of your local folder mount: ' -i '/mnt/d/tmp/pv' LOCAL_MOUNT_BASE
fi

source ./scripts/configure-azure-secret.sh

# puts envs into a comma separated list with dollar signs
env_list=$(env | cut -d '=' -f 1 | sed 's/^PATH$//' | sed 's/^/\$/;s/$/,/' | tr -d '\n' | sed 's/,$//')

# now only env variables are replaced in values template
envsubst "${env_list}" < ./values-iste_linux.tmpl | tee values-iste_linux.yaml

envsubst "${env_list}" < ./values-test-azure.tmpl | tee values-test-azure.yaml

# start test
helm dependency update ../icm-as # wait for https://github.com/helm/helm/issues/2247
helm dependency update ../icm
helm dependency update .
helm upgrade --install ${HELM_DRY_RUN} ${HELM_JOB_NAME} . -f ./values-iste_linux.yaml -f ./values-test-azure.yaml
