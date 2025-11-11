#!/usr/bin/env bash

set -eu pipefail

# Create a new storage account and copy necessary files if it doesn't exist yet
if [[ "$HAS_AZURE_STORAGE_ACCOUNT" == 'n' ]]; then
    AZURE_STORAGE_ACCOUNT="$(uuidgen | tr -d '-' | tr 'A-Z' 'a-z' | cut -c1-24)"
    AZURE_RESOURCE_GROUP="ateam-common"

    echo "Creating new storage account with name $AZURE_STORAGE_ACCOUNT in resource group $AZURE_RESOURCE_GROUP..."

    az storage account create \
      --name "$AZURE_STORAGE_ACCOUNT" \
      --resource-group "$AZURE_RESOURCE_GROUP" \
      --location "northeurope" \
      --sku Standard_LRS \
      --kind StorageV2 \
      1>/dev/null
fi

# Try to fetch the first storage account key
STORAGE_KEY=$(az storage account keys list \
--resource-group "$AZURE_RESOURCE_GROUP" \
--account-name "$AZURE_STORAGE_ACCOUNT" \
--query "[0].value" \
--output tsv 2>/dev/null)

echo "✅ Successfully retrieved storage account key"

# Check if key retrieval succeeded
if [ -z "$STORAGE_KEY" ]; then
    echo "❌ Failed to get storage account key"
    exit 1
fi

source ./scripts/copy-testdata-azure.sh

# Create azure secret to access the storage account
kubectl create secret generic azure-secret \
  --from-literal=azurestorageaccountname="$AZURE_STORAGE_ACCOUNT" \
  --from-literal=azurestorageaccountkey="$STORAGE_KEY" \
  1>/dev/null

echo "✅ Successfully created kubernetes secret for azure storage account"
