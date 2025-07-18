#!/usr/bin/env bash
HELM_DRY_RUN=""

SERVER_DIRECTORY="not_used"
CONFIG_DIRECTORY="/data/iste-icm-11-replication/config"
RESULT_DIRECTORY="/data/iste-icm-11-replication/result"
HELM_DIRECTORY="/data/iste-icm-11-replication"
WORKSPACE_DIRECTORY="/data"

NODENAME="true"

ICM_WEBSERVER_IMAGE="intershophub/icm-webadapter:2.6.0"
ICM_WEBADAPTER_AGENT_IMAGE="intershophub/icm-webadapteragent:4.0.1"
SERVER_DIRECTORY_GROUP="intershop"
SERVER_DIRECTORY_USER="intershop"
DNS_ZONE_NAME="test.intershop.com"

DATABASE_TYPE="mssql"
DATABASE_USER_EDIT="intershop_edit"
DATABASE_CONNECTION_STRING_EDIT="jdbc:sqlserver://<your database ip>:1433;databaseName=intershop_edit"
DATABASE_USER_LIVE="intershop_live"
DATABASE_CONNECTION_STRING_LIVE="jdbc:sqlserver://<your database ip>:1433;databaseName=intershop_live"
