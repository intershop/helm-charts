# Operator-owned Azure bootstrap — NOT EXECUTED

This is an infrastructure recipe, **not approval to deploy, migrate or delete data**.
The chart never runs it. Use a new disposable installation for runtime proofs.
No administrator credential, account key, connection string, token, or secret belongs
in these files. Use the operator's already approved Azure CLI identity; the script
does not log in, discover secrets, grant itself privileges, or publish images.

## Explicit input and scope

Create a non-secret JSON input in an operator-controlled directory. Every input
below is required by `bootstrap.ps1` (sample symbols must be replaced):

```json
{
  "subscriptionId": "<subscription UUID>",
  "tenantId": "<Azure directory UUID>",
  "resourceGroup": "<new platform resource group>",
  "resourceGroupRegion": "<approved Azure region>",
  "mediaRegion": "<approved media region>",
  "controlRegion": "<approved control region>",
  "mediaAccount": "<globally unique media account name>",
  "controlAccount": "<different globally unique control account name>",
  "sku": "<approved Standard_LRS or Standard_ZRS>",
  "installationId": "<immutable installation ID>",
  "aksOidcIssuer": "<exact AKS OIDC issuer URL, including trailing slash>",
  "namespace": "<Helm installation namespace>",
  "fullname": "<exact chart fullnameOverride, at most 40 characters>",
  "armEndpoint": "<approved Azure Resource Manager HTTPS endpoint>",
  "approvedCompanyTenant": "<approved company directory UUID>",
  "companyIssuer": "<exact single-company OIDC issuer URL>",
  "approvedOrigins": ["<approved HTTPS shop/upload origin>"],
  "controlAllowedIps": ["<operator NAT IPv4>", "<cluster egress NAT IPv4/CIDR>"],
  "blobSoftDeleteDays": 14,
  "containerSoftDeleteDays": 14,
  "corsMaxAgeSeconds": 300,
  "tables": {
    "registry": "TenantRegistry",
    "directory": "TenantDirectory",
    "credentials": "ShopCredentials",
    "runtime": "TenantRuntime",
    "drain": "TenantDrain",
    "proofs": "TenantProofs"
  },
  "identities": {
    "widget": "<unique managed identity name>",
    "archive": "<unique managed identity name>",
    "rest": "<unique managed identity name>",
    "coordinator": "<unique managed identity name>",
    "control-api": "<unique managed identity name>",
    "provisioner": "<unique managed identity name>",
    "imgproxy": "<unique managed identity name>"
  },
  "roles": {
    "tableReader": "<Storage Table Data Reader role-definition UUID>",
    "tableContributor": "<Storage Table Data Contributor role-definition UUID>",
    "blobDelegator": "<Storage Blob Delegator role-definition UUID>",
    "containerManager": "<new platform-approved custom role-definition UUID>",
    "dataReader": "<new distinct custom role-definition UUID>",
    "dataWriter": "<new distinct custom role-definition UUID>",
    "dataReadWriter": "<new distinct custom role-definition UUID>",
    "dataManager": "<new distinct custom role-definition UUID>"
  }
}
```

The retention numbers are examples requiring legal/operations approval, **not**
a promise of erasure within that period. Obtain approved built-in role UUIDs from
the platform team; validate their definitions before running. The operator needs
resource creation plus bounded role-definition/assignment rights at the exact
resource scopes. Do not grant those rights to application identities.

The script is Windows PowerShell-compatible. From this chart directory:

```powershell
# Offline input validation and exact role/assignment plan; no Azure commands.
.\docs\bootstrap.ps1 -InputFile .\operator-bootstrap.json
# Following commands are operator instructions only, not executed by implementation:
.\docs\bootstrap.ps1 -InputFile .\operator-bootstrap.json -Apply -WhatIf
.\docs\bootstrap.ps1 -InputFile .\operator-bootstrap.json -Apply
```

`-Apply` requires confirmation, verifies the existing login's subscription/tenant,
creates/updates explicitly tagged platform infrastructure, and stops on errors.
Default dry-run prints the exact custom role definitions and scoped/conditioned
assignment plan from `bootstrap-policy.ps1`. Assignment UUIDs are deterministic
over principal, definition, scope and condition, so an unchanged approved policy
can be reapplied without duplicating grants. A changed policy does **not** revoke
old grants automatically: the operator must reconcile/remove superseded grants
and reverify effective permissions before renewing the attestation.
Keep `.bootstrap-artifacts` in the chart working directory; do not commit it.
Capture output identity IDs into the environment values. Do not blindly retry
after partial failure: inspect ownership tags, locations, ACL/firewall state,
existing custom role definitions and federation subjects. Never reuse an existing
installation's names/role UUID. Script ownership checks do not replace platform review.

## Accounts, Tables, identities and federation

Two StorageV2 accounts use HTTPS/TLS1.2 and disable shared-key authorization:

* **Media:** account permits anonymous blobs, not automatically anonymous containers.
  Public network access is intentional for direct browser SAS uploads and public
  images. The script creates **no tenant containers**. Provisioner creates opaque
  `t-<storage-id>-images` with `PublicAccessType.BLOB` and `t-<storage-id>-upload`
  with no anonymous access. Anonymous container listing must fail.
* **Control:** anonymous blobs disabled, default-deny firewall, explicit operator
  and cluster public egress addresses. Six distinct tables are created through ARM without
  account keys. TenantRegistry holds authoritative entities, operations and audit
  state; TenantDirectory and ShopCredentials are separately permissioned read
  projections. TenantRuntime holds cluster admission/usage/resize reservations.
  TenantDrain holds coordinator-only drain observations. TenantProofs is
  an **operator-written** access/deletion evidence table, never writable by applications.

Each of seven user-assigned identities gets exactly one federated subject:
`system:serviceaccount:<namespace>:<fullname>-<role>`; the roles are `widget`,
`archive`, `rest`, `coordinator`, `control-api`, `provisioner`, `imgproxy`.
The federation audience is `api://AzureADTokenExchange`; the issuer is the
operator-supplied AKS issuer, not the company login issuer. Azure tenant ID is not
an application tenant ID. Install the AKS workload identity webhook/OIDC support
through platform administration before Helm. No Kubernetes RBAC roles are granted.

| Identity | Control tables | Media rights |
|---|---|---|
| widget | Directory + Credentials reader; Runtime contributor for upload admission | `t-*-images` and `t-*-upload`: blob read/write/delete; separate account **Blob Delegator** for user-delegation SAS |
| archive | Directory reader; Runtime contributor for cluster reservations | `t-*-images`: blob write; `t-*-upload`: blob read/write (jobs/logs/leases) |
| rest | Directory reader; Runtime contributor for resize reservations | `t-*-images`: blob write only; **no upload container** |
| coordinator | Directory reader; Runtime contributor; **sole Drain contributor** | `t-*-upload`: blob read/write/delete for reconciliation/terminal cleanup; no images |
| control-api | Registry contributor only; no projection publication | **None**, no container administration |
| provisioner | Registry, Directory, Credentials contributor; Drain + Proofs reader | Custom container metadata/create/ACL/delete role at media account; **no blob data or role-assignment rights** |
| imgproxy | **None** | `t-*-images`: **blob read only**, no upload/control/delegation permission |

TenantDrain is independently permissioned: widget/archive/rest have **no** grants,
coordinator alone writes, and provisioner only reads. Names must remain distinct.
Changing an existing installation's table layout requires operator migration and
removal of old broad grants; a Helm render does not revoke Azure permissions.

### Automatic pool RBAC, followed by independently verified attestation

After approval, `bootstrap.ps1 -Apply` installs the **complete pool role policy**.
No per-tenant operator assignment is required for future matching containers:
the provisioner creates them, but has no RBAC delegation. All data grants use
custom definitions with empty `actions` and only the exact `.../containers/blobs/`
`read`, `write`, or `delete` data actions above. `write` covers Put Blob, Put Block,
Put Block List, blob leases, and conditional replacement of job/log blobs.
There is no append-block, move, tag, container management, account-key or RBAC
write permission in a data role. Validate these exact SDK operations in the
effective-access probe; do not silently substitute a broad built-in contributor.

Each data assignment is scoped to the **one approved media account**, with
conditionVersion `2.0` and one mandatory condition:

```text
(@Resource[Microsoft.Storage/storageAccounts/blobServices/containers:name] StringLike 't-*-images')
(@Resource[Microsoft.Storage/storageAccounts/blobServices/containers:name] StringLike 't-*-upload')
```

Widget receives two separate conditioned assignments; archive receives separate
image-write and upload-read/write assignments. REST never receives upload rights;
imgproxy only reads published image containers. Blob Delegator is a **separate**
account-scoped action grant to widget only; a user-delegation key does not itself
grant arbitrary blob access. All custom data grants exclude container actions.
Only the provisioner's separate container manager can create/delete/set ACLs in
the pool, and only the operator can create identities, federations, definitions
or assignments. Provisioner has neither account keys nor identity/RBAC writes.

**ABAC scope is not application-tenant isolation between trusted service identities.**
Each trusted shared service can perform its permitted operations across matching
containers. Directory binding, credentials, canonical paths, scoped SAS and JWT
checks enforce tenant boundaries. Nonmatching containers, upload reads by imgproxy,
REST upload operations, anonymous upload reads/listing and cross-tenant browser
grants must fail. Inherited/group/legacy grants are additive: the ABAC condition
cannot restrict another broader assignment. Check all effective grants.

Bootstrap **never writes a proof** and a successful ARM assignment is **not**
evidence that permissions have propagated or that CORS/isolation works.
An approved platform operator or separate probe authority (not any application
identity) receives table-scoped proof-writer authority outside this script, runs
real checks using the actual federated principals and browser origins, and only
then writes this expiring entity in TenantProofs:

| Property | Required value |
|---|---|
| PartitionKey | Exact `control.installationId` |
| RowKey | `pool-access` |
| schemaVersion | Integer `1` |
| installationId | Same immutable installation ID |
| accountEndpoint | Exact `azure.mediaEndpoint` |
| credentialReference | `workload-identity` |
| imagesPattern / uploadPattern | `t-*-images` / `t-*-upload` |
| accessVerified / corsVerified / isolationVerified | Boolean `true`, only after effective checks pass |
| approvedOrigins | Comma-separated exact HTTPS origins successfully checked |
| expiresAt | Future ISO instant within approved evidence validity |
| evidenceReference | Non-secret durable reference to principal/role/condition, CORS and isolation results |

Check two newly created matching pairs, plus negative/nonmatching targets, and
record exact account/identity/role-policy versions and effective results. Approval
attests the **future-container pool policy**, not merely access to one existing pair.
Repeat checks on policy/origin/identity changes or before expiry. The provisioner
can automatically activate future matching targets only with an unexpired exact
installation/account/credential/pattern proof, all tenant origins a subset of the
approved list, and its own verified ACL/ownership. Missing, stale, malformed or
mismatched evidence blocks activation. No application can manufacture approval.
Deletion still requires a separate **tenant/revision-specific** cache/retention
proof plus fresh drain and expired grants; `pool-access` is never deletion evidence.

Existing per-tenant operation/revision-bound access proofs remain an alternative,
including deployments deliberately not approving a shared pool policy.
For that alternative only, operators may use exact-container assignments:

```powershell
$containerScope = "$MediaAccountResourceId/blobServices/default/containers/$VerifiedContainerName"
az role assignment create --subscription $SubscriptionId `
  --assignee-object-id $ApprovedPrincipalObjectId --assignee-principal-type ServicePrincipal `
  --role $ApprovedDataRoleDefinitionId --scope $containerScope
```

Use the same exact operation matrix above, wait for propagation, and publish the
per-tenant proof using the control repository's schema only after actual checks.
Never derive grants from untrusted tenant-supplied URLs, identities or role IDs.

## Company OIDC and secrets

Company identity administrators must register a single-company confidential web
application, require assignment, enforce approved membership/MFA policies, configure
the exact `https://<control-host>/portal` callback and post-logout URL, and supply
the issuer, client ID, token audience, roles/groups claim and approved member/operator
role values. The issuer must belong to `approvedCompanyTenant`; generic
`common`/`organizations` authorities or arbitrary tenants are not acceptable.
The approved-company value is an operator assertion, not a separate application
claim check; exact issuer + audience + company-assigned role checks enforce login.
Do not give every company user operator membership.
`oidc.audience` **must equal** `oidc.clientId`, matching the control StartupGate.
The schema requires both nonempty strings; template validation enforces equality.

Provision namespace secrets separately through the approved secret manager:
OIDC client secret, OIDC session encryption secret, control CSRF key (at least 32
characters), worker RSA private key (widget only), worker public/JWKS key (REST only),
and imgproxy hex signing key (at least 32 bytes) plus salt (at least 16 bytes).
Helm accepts only **names and keys of existing secrets**, never secret values.
No shop credential belongs in this chart. Retain old JWT verification keys through
the maximum 60-second token TTL during key-ID rotation. Rotate imgproxy key/salt
with URL/cache compatibility planning. Bump only affected component
`rolloutRevision` values when updating external secret contents.

## Browser CORS, reachability, caches and retained data

Use exactly the same reviewed `approvedOrigins` set in bootstrap and chart
`origins.approved`. The script replaces the media account's Blob service CORS with
one approved rule (PUT/GET/HEAD/OPTIONS, content-type/x-ms-* headers, ETag exposed).
Only run on the new owned pool; replacing CORS on a shared pre-existing account
could break other applications. The browser sends SAS uploads directly to Azure,
without shop Authorization headers. Verify preflight, chunked Put Block/Put Block
List and finalize with both demo origins. SAS authorizes; CORS does **not**.

CORS is account-wide, not container/tenant-scoped. The owner API accepts a subset
of the approved set; adding an origin requires platform review, account CORS
reconciliation, verification and a policy release. Azure supports at most five
CORS rules and a bounded service-properties payload (review current limits,
including origin length); one rule plus 64 values is **not a guarantee it fits**.
Use a shared approved upload origin before exceeding those limits, not `*`.
Private-endpoint-only media accounts are incompatible with arbitrary browser
uploads/public blob URLs without an alternate approved upload/delivery gateway.
This chart's egress policy targets public Azure endpoints and intentionally does
not enable private address ranges or IMDS. Review regional firewall support and
NAT reachability; do not silently switch control default action to Allow.

Media versioning, blob soft delete and container soft delete are enabled with
explicit retention; **no storage lifecycle deletion rule** is installed. A generic
age rule must never delete active uploads, `.jobs` records or images. Coordinator
retention applies only terminal records. Inventory snapshots, versions, soft-deleted
containers and legal holds before deletion; removing a current blob/container is
not immediate physical erasure. Retention cleanup is a separately approved operator
action, never part of bootstrap/cutover validation.

Public image caches use tenant namespace + normalized path + transform (and
version/ETag as supported); never collapse tenant paths in CDN/HAProxy keys.
`imgproxy.ttlSeconds` bounds new proxy responses, **not pre-existing CDN caches or
direct blob Cache-Control**. Overwrite/delete requires purge at every cache layer
or waiting documented maximum TTLs; prefer versioned immutable image paths.
Management, credentials, SAS, finalize and job responses must be `no-store` and
bypass intermediary caches. Suspension revokes management, not public bytes already
downloaded/cached. Obtain explicit cache+retention deletion evidence before
publishing a deletion proof. No cache purge or deletion is executed by these files.
