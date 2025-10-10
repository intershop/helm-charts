# Azure Workload Identity Support for ICM-AS Helm Chart

## Summary of Changes

This implementation adds comprehensive Azure Workload Identity (managed identity) support to the ICM-AS Helm chart, enabling secure authentication to Azure services without storing credentials in the application.

## Files Modified

### 1. `values.yaml`

- Added `managedIdentity` configuration section with:
  - `enabled`: Boolean to enable/disable managed identity
  - `clientId`: Azure managed identity client ID
  - `tenantId`: Azure AD tenant ID (optional)
  - `additionalEnvVars`: Array for additional environment variables

### 2. `templates/_helpers.tpl`

- Added `icm-as.serviceAccountName` helper function
- Added `icm-as.managedIdentityEnv` helper for environment variables
- Added `icm-as.managedIdentityVolumeMounts` helper (for reference)
- Added `icm-as.managedIdentityVolumes` helper (for reference)

### 3. `templates/serviceaccount.yaml`

- Modified to create service account when managed identity is enabled
- Added Azure Workload Identity annotations:
  - `azure.workload.identity/client-id`
  - `azure.workload.identity/tenant-id`

### 4. `templates/as-deployment.yaml`

- Added managed identity annotations and labels to pod template
- Updated service account name condition to include managed identity
- Added managed identity environment variables
- Service account automatically created when managed identity is enabled

### 5. `templates/jobserver-deployment.yaml`

- Added managed identity support for job server deployment
- Same annotations, labels, and environment variables as main deployment

### 6. `templates/_volumeMounts.tpl`

- Added azure-identity-token volume mount at `/var/run/secrets/azure/tokens`

### 7. `templates/_volumes.tpl`

- Added azure-identity-token projected volume with service account token

## Files Created

### 1. `example-managed-identity-values.yaml`

- Example configuration showing how to enable managed identity
- Includes best practices and recommended settings

### 2. `tests/managed-identity_test.yaml`

- Helm unit tests for managed identity functionality
- Tests service account creation, annotations, environment variables, volumes

## Documentation Updated

### 1. `README.asciidoc`

- Added new section "Azure Workload Identity (Managed Identity)"
- Includes prerequisites, configuration examples, and usage instructions
- Documents the environment variables available to applications

## Configuration Example

```yaml
# Enable managed identity
managedIdentity:
  enabled: true
  clientId: "your-managed-identity-client-id"
  tenantId: "your-azure-ad-tenant-id"
  additionalEnvVars:
    - name: AZURE_SUBSCRIPTION_ID
      value: "your-subscription-id"

# Service account must be created
serviceAccount:
  create: true
```

## What This Enables

When managed identity is enabled, the chart will:

1. **Create Service Account**: With proper Azure Workload Identity annotations
2. **Configure Pod Identity**: Add required annotations and labels to pods
3. **Mount Identity Token**: As a projected volume for Azure SDK authentication
4. **Set Environment Variables**: For Azure SDK to automatically discover identity
5. **Support Job Server**: Same managed identity configuration applies to job server

## Environment Variables Available to Applications

- `AZURE_CLIENT_ID`: The client ID of the managed identity
- `AZURE_TENANT_ID`: The tenant ID (if configured)
- `AZURE_FEDERATED_TOKEN_FILE`: Path to the federated token file
- Any additional environment variables configured in `additionalEnvVars`

## Prerequisites

- Azure Kubernetes Service (AKS) cluster with Workload Identity enabled
- Azure User-Assigned Managed Identity created
- Workload Identity federation configured between Kubernetes service account and managed identity

## Benefits

- **Security**: No credentials stored in Kubernetes secrets or environment variables
- **Automatic Rotation**: Azure handles token rotation automatically
- **Native Integration**: Works seamlessly with Azure SDKs
- **Audit Trail**: Azure AD provides comprehensive audit logs
- **Principle of Least Privilege**: Can assign specific roles to the managed identity

This implementation follows Azure best practices for workload identity and is compatible with the latest Azure Workload Identity features.
