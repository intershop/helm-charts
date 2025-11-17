#!/usr/bin/env bash

# Script to check if the needed kubernetes secrets exist

# List of secrets to check
secrets=(
  "tls ingress-tls-csi"
  "docker-registry dockerhub"
)

for entry in "${secrets[@]}"; do
  type=$(echo "$entry" | awk '{print $1}')
  identifier=$(echo "$entry" | awk '{print $2}')

  if kubectl get secret "$identifier" >/dev/null 2>&1; then
    echo "✅ Secret '$identifier' (type: $type) exists."
  else
    echo "❌ Secret '$identifier' (type: $type) does not exist. Please create it."
    exit 1
  fi
done
