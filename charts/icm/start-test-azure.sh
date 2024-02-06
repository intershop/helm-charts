#!/usr/bin/env bash

set -eu pipefail

set -o allexport
source start-test-local_vars.sh
read -e -p 'Helm chart name: ' -i 'icm-11-test' HELM_JOB_NAME
read -e -p 'Testsuite: ' -i 'tests.remote.com.intershop.cms.suite.PageListingTestSuite' TESTSUITE
read -e -p 'Test image: ' -i 'intershophub/icm-as-test:11.9.0' ICM_TEST_IMAGE
read -e -p 'The pull secret for the icm-as+testrunner image (e.g. dockerhub or icmbuildsnapshot): ' -i 'dockerhub' ICM_AS_PULL_SECRET
read -e -p 'The pull secret for the icm-proxy image: ' -i 'dockerhub' ICM_PROXY_PULL_SECRET
set +o allexport

# puts envs into a comma separated list with dollar signs
env_list=$(env | cut -d '=' -f 1 | sed 's/^PATH$//' | sed 's/^/\$/;s/$/,/' | tr -d '\n' | sed 's/,$//')

# now only env variables are replaced in values template
envsubst "${env_list}" < ./values-iste_linux.tmpl | tee values-iste_linux.yaml

#nvsubst "${env_list}" < ./values-test-local.tmpl | tee values-test-local.yaml

# create needed folders
#source start-test-local_dir-create.sh

# generate proxy certificate
#mkdir -p ../icm-proxy/ssl-certificates
#openssl genrsa > ../icm-proxy/ssl-certificates/privkey.pem
#openssl req -new -x509 -subj "/CN=my.root" -key ../icm-proxy/ssl-certificates/privkey.pem > ../icm-proxy/ssl-certificates/fullchain.pem

# start test
helm dependency update ../icm-as # wait for https://github.com/helm/helm/issues/2247
helm dependency update .
helm upgrade --install ${HELM_DRY_RUN}${HELM_JOB_NAME} . -f ./values-iste_linux.yaml
