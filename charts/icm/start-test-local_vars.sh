#!/usr/bin/env bash
HELM_DRY_RUN=""
HELM_JOB_NAME="icm-11-test"
KUBECONFIG=/mnt/c/Users/KHauser/.kube/config

SERVER_DIRECTORY="not_used"
CONFIG_DIRECTORY="/data/testplans/1/testsuites/1/workspace/helm/iste-icm-11/config"
RESULT_DIRECTORY="/data/testplans/1f7fec27-2db5-4c31-9f49-29f6420d595e/testsuites/929276/workspace/helm/iste-icm-11/result"
HELM_DIRECTORY="/data/testplans/1/testsuites/1/workspace/helm/iste-icm-11"
WORKSPACE_DIRECTORY="/data/testplans/1/testsuites/1/workspace/"

DATABASE_TYPE="mssql"
DATABASE_HOST="10.0.206.118"
DATABASE_SCHEMA="ISTE_ICM_DEV"
DATABASE_CONNECTION_STRING="jdbc:sqlserver://10.0.206.118:1433;databaseName=ISTE_ICM_DEV;encrypt=false;sslProtocol=TLSv1.2;"
DATABASE_USER="ISTE_ICM_DEV"

SERVER_DOCKER_IMAGE="unknown"
#TESTSUITE="tests.remote.com.intershop.seo.suite.Seo01TestSuite"
TESTSUITE="tests.remote.com.intershop.organization.suite.Organization02TestSuite"
ICM_TEST_IMAGE="icmbuild.azurecr.io/intershop/icm-as-test:11.0.11-SNAPSHOT"

TESTRUNNER_DIRECTORY="/intershop/testrunner"
NODENAME="true"

ICM_WEBSERVER_IMAGE="intershophub/icm-webadapter:2.4.4"
ICM_WEBADAPTER_AGENT_IMAGE="intershophub/icm-webadapteragent:4.0.0"
SERVER_DIRECTORY_GROUP="intershop"
SERVER_DIRECTORY_USER="intershop"
VERSION="2023-01-16T22:46:48.830Z"

