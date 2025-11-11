#!/usr/bin/env bash

set -eu pipefail

BASE_DIR=$LOCAL_MOUNT_BASE

VIRT_TYPE=$(systemd-detect-virt)
if [ $VIRT_TYPE = "wsl" ]; then
  BASE_DIR=$(echo "$BASE_DIR" | sed "s|/run/desktop/mnt/host|/mnt|")
fi

# create needed folders
mkdir -p $BASE_DIR/sites
mkdir -p $BASE_DIR/sites-live
mkdir -p $BASE_DIR/mssql/data
mkdir -p $BASE_DIR/mssql/backup

mkdir -p $BASE_DIR/testdata/iste-icm-11/result
mkdir -p $BASE_DIR/testdata/iste-icm-11/config
mkdir -p $BASE_DIR/testdata/iste-icm-11/server-logs
