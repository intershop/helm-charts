#!/usr/bin/env bash
HELM_DRY_RUN=""
HELM_JOB_NAME="icm-11-test"

SERVER_DIRECTORY="not_used"
CONFIG_DIRECTORY="/data/testplans/1/testsuites/1/workspace/helm/iste-icm-11/config"
RESULT_DIRECTORY="/data/testplans/1/testsuites/1/workspace/helm/iste-icm-11/result"
HELM_DIRECTORY="/data/testplans/1/testsuites/1/workspace/helm/iste-icm-11"
WORKSPACE_DIRECTORY="/data/testplans/1/testsuites/1/workspace"

SERVER_DOCKER_IMAGE="unknown"
TESTSUITE="tests.remote.com.intershop.cms.suite.ComponentTemplateGeneralTestSuite"
#TESTSUITE="tests.remote.com.intershop.seo.suite.Seo01TestSuite"
#TESTSUITE="tests.remote.com.intershop.productcatalog.suite.Product124TestSuite"
#TESTSUITE="tests.remote.com.intershop.organization.suite.Organization02TestSuite"
ICM_TEST_IMAGE="icmbuild.azurecr.io/intershop/icm-as-test:82631.6851613872-SNAPSHOT"

TESTRUNNER_DIRECTORY="/intershop/testrunner"
NODENAME="true"

ICM_WEBSERVER_IMAGE="intershophub/icm-webadapter:2.4.4"
ICM_WEBADAPTER_AGENT_IMAGE="intershophub/icm-webadapteragent:4.0.0"
SERVER_DIRECTORY_GROUP="intershop"
SERVER_DIRECTORY_USER="intershop"
