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
read -e -p 'The pull secret for the mssql image (e.g dockerhub): ' -i 'dockerhub' MSSQL_PULL_SECRET
read -e -p 'The pull secret for the icm-wa+waa image: ' -i 'dockerhub' ICM_WEB_PULL_SECRET
set +o allexport

# puts envs into a comma separated list with dollar signs
env_list=$(env | cut -d '=' -f 1 | sed 's/^PATH$//' | sed 's/^/\$/;s/$/,/' | tr -d '\n' | sed 's/,$//')

# now only env variables are replaced in values template
envsubst "${env_list}" < ./values-iste_linux.tmpl | tee values-iste_linux.yaml

envsubst "${env_list}" < ./values-test-local.tmpl | tee values-test-local.yaml

# create needed folders
source ./scripts/start-test-local_dir-create.sh

# Copy dumpfile directory into testdata so it's available at /data/dumpfile in the container
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
PROJECT_ROOT=$(cd "$SCRIPT_DIR/../.." && pwd)
if [ -d "$PROJECT_ROOT/dumpfile" ]; then
  echo "Copying dumpfile directory into testdata..."
  TESTDATA_BASE=$LOCAL_MOUNT_BASE/testdata
  VIRT_TYPE=$(systemd-detect-virt 2>/dev/null || echo "none")
  if [ "$VIRT_TYPE" = "wsl" ]; then
    TESTDATA_BASE=$(echo "$TESTDATA_BASE" | sed "s|/run/desktop/mnt/host|/mnt|")
  fi
  mkdir -p "$TESTDATA_BASE/dumpfile"
  cp -v "$PROJECT_ROOT"/dumpfile/*.dmp "$TESTDATA_BASE/dumpfile/" 2>/dev/null || echo "No .dmp files found in $PROJECT_ROOT/dumpfile, skipping."
  echo "Dumpfile copy complete."
else
  echo "No dumpfile directory found at $PROJECT_ROOT/dumpfile, skipping copy."
fi

# Update dependencies from source charts if they exist
# When running standalone with pre-bundled charts/ this is skipped (happens in local execution)
if [ -d "../icm-as" ]; then
  helm dependency update ../icm-as # wait for https://github.com/helm/helm/issues/2247
fi
if [ -d "../icm" ]; then
  helm dependency update ../icm
fi
helm dependency update .

helm upgrade --install ${HELM_DRY_RUN} ${HELM_JOB_NAME} . -f ./values-iste_linux.yaml -f ./values-test-local.yaml
