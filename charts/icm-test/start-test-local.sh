#!/usr/bin/env bash

set -eu pipefail

set -o allexport
source ./scripts/start-test-local_vars.sh

# check Kubernetes secrets
source ./scripts/check-kubernetes-secrets.sh

read -e -p 'Helm chart name: ' -i 'icm-test' HELM_JOB_NAME

DEFAULT_TESTSUITE='tests.remote.com.intershop.cms.suite.PageListingTestSuite'
TESTSUITE="${TESTSUITE:-$DEFAULT_TESTSUITE}"
read -e -p 'Testsuite: ' -i "$TESTSUITE" TESTSUITE || { echo "Error reading input"; exit 1; }

DEFAULT_ICM_TEST_IMAGE='intershophub/icm-as-test:14.0.1'
ICM_TEST_IMAGE="${ICM_TEST_IMAGE:-$DEFAULT_ICM_TEST_IMAGE}"
read -e -p 'Test image: ' -i "$ICM_TEST_IMAGE" ICM_TEST_IMAGE || { echo "Error reading input"; exit 1; }

# check additional optional Kubernetes secret (icmbuildsnapshot) if the test image is not from dockerhub
if [[ ! "$ICM_TEST_IMAGE" == intershophub* ]]; then
    echo "Checking icmbuildsnapshot secret since test image is not from dockerhub..."
    if kubectl get secret icmbuildsnapshot >/dev/null 2>&1; then
        echo "✅ Secret 'icmbuildsnapshot' exists."
    else
        echo "❌ Secret 'icmbuildsnapshot' does not exist. Please create it."
        exit 1
    fi
fi

read -e -p 'Base path of your local folder mount: ' -i '/run/desktop/mnt/host/d/tmp/pv' LOCAL_MOUNT_BASE
read -e -p 'The pull secret for the icm-as+testrunner image (e.g. dockerhub or icmbuildsnapshot): ' -i 'dockerhub' ICM_AS_PULL_SECRET
read -e -p 'The pull secret for the icm-wa+waa image: ' -i 'dockerhub' ICM_WEB_PULL_SECRET
set +o allexport

# puts envs into a comma separated list with dollar signs
env_list=$(env | cut -d '=' -f 1 | sed 's/^PATH$//' | sed 's/^/\$/;s/$/,/' | tr -d '\n' | sed 's/,$//')

# now only env variables are replaced in values template
envsubst "${env_list}" < ./values-iste_linux.tmpl | tee values-iste_linux.yaml

envsubst "${env_list}" < ./values-test-local.tmpl | tee values-test-local.yaml

# create needed folders
source ./scripts/start-test-local_dir-create.sh

helm dependency update ../icm-as # wait for https://github.com/helm/helm/issues/2247
helm dependency update ../icm
helm dependency update .
helm upgrade --install ${HELM_DRY_RUN} ${HELM_JOB_NAME} . -f ./values-iste_linux.yaml -f ./values-test-local.yaml
