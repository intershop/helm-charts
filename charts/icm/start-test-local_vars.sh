#!/usr/bin/env bash
HELM_DRY_RUN=""

SERVER_DIRECTORY="not_used"
CONFIG_DIRECTORY="/data/testplans/1/testsuites/1/workspace/helm/iste-icm-11/config"
RESULT_DIRECTORY="/data/testplans/1/testsuites/1/workspace/helm/iste-icm-11/result"
HELM_DIRECTORY="/data/testplans/1/testsuites/1/workspace/helm/iste-icm-11"
WORKSPACE_DIRECTORY="/data/testplans/1/testsuites/1/workspace"

NODENAME="true"

ICM_WEBSERVER_IMAGE="intershophub/icm-webadapter:2.4.5"
ICM_WEBADAPTER_AGENT_IMAGE="intershophub/icm-webadapteragent:4.0.0"
SERVER_DIRECTORY_GROUP="intershop"
SERVER_DIRECTORY_USER="intershop"
