#!/usr/bin/env bash

set -eu pipefail

# If the Azure Storage account existed previously then the data is already there
if [[  "$HAS_AZURE_STORAGE_ACCOUNT" == 'y' ]]; then
    return 0
fi

FILE_SHARES=("icm-sites" "iste-mssql-backup" "iste-mssql-data" "iste-nfs")

# Create necessary file shares
for SHARE in "${FILE_SHARES[@]}"; do
  az storage share create \
    --account-name $AZURE_STORAGE_ACCOUNT \
    --name $SHARE \
    --account-key $STORAGE_KEY \
    --quota 50 \
    1>/dev/null
  echo "✅ File share created: $SHARE"
done

# Check which az is being used
AZ_PATH=$(which az)

# Convert base folder if az is Windows version
if [[ "$AZ_PATH" == /mnt/c/* ]]; then
    # Windows az needs Windows-style paths
    BASE_FOLDER=$(wslpath -w "$LOCAL_MOUNT_BASE")
else
    # Linux az (WSL) can use /mnt paths
    BASE_FOLDER="$LOCAL_MOUNT_BASE"
fi

#Copy necessary data from local folders
az storage file upload-batch \
  --account-name $AZURE_STORAGE_ACCOUNT \
  --account-key $STORAGE_KEY \
  --destination "icm-sites" \
  --source $BASE_FOLDER/sites \
    1>/dev/null

echo "✅ Copied data into icm-sites"

az storage file upload-batch \
  --account-name $AZURE_STORAGE_ACCOUNT \
  --account-key $STORAGE_KEY \
  --destination "iste-mssql-backup" \
  --source $BASE_FOLDER/mssql/backup \
    1>/dev/null

echo "✅ Copied data into iste-mssql-backup"

az storage file upload-batch \
  --account-name $AZURE_STORAGE_ACCOUNT \
  --account-key $STORAGE_KEY \
  --destination "iste-mssql-data" \
  --source $BASE_FOLDER/mssql/data \
    1>/dev/null

echo "✅ Copied data into iste-mssql-data"

az storage file upload-batch \
  --account-name $AZURE_STORAGE_ACCOUNT \
  --account-key $STORAGE_KEY \
  --destination "iste-nfs" \
  --source $BASE_FOLDER/testdata \
    1>/dev/null

echo "✅ Copied data into iste-nfs"
