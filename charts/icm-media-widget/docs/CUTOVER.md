# Production cutover BLOCKED

No cloud resources, data copies, tenant changes, role grants, credential rotation,
CDN purges or production deploys were executed in this implementation.
Offline chart success is not runtime acceptance. Obtain explicit operator approval
and retain the evidence below before scheduling a **breaking** cutover.

## Disposable installation acceptance

- [ ] Seven approved, immutable application artifacts start under non-root,
      read-only filesystems and the configured memory/scratch/processing budgets.
      Verify every environment property against the final application builds.
- [ ] Workload federation selects the correct distinct principal for every pod.
      Missing federation fails closed; imgproxy must never use node identity.
- [ ] Actual Azure Tables ETags, conditional writes and schema-version rejection
      work. Workers cannot read ShopCredentials, TenantRegistry or TenantProofs.
- [ ] Six distinct tables exist. TenantRuntime admission/usage reservations are
      separate from TenantDrain. Coordinator is the sole Drain contributor;
      provisioner reads it; widget/archive/REST cannot access it. Remove inherited
      or legacy grants that would bypass this isolation.
- [ ] User-delegation SAS grants only create/write to the allocated upload blob,
      HTTPS-only with bounded expiry; images, `.jobs`, other jobs/tenants and read/tag
      privileges are denied. Admission/size limits and finalize are exercised.
- [ ] Approve/install the bootstrap's exact ABAC pool assignments, then verify
      effective operations with actual principals, two fresh matching pairs and
      nonmatching/forbidden targets. Check inherited/group grants, browser CORS,
      anonymous ACLs, cross-tenant credentials and SAS. Only after passing, a
      separately authorized operator/probe writes installation-scoped `pool-access`
      attestation. Future matching containers activate without per-tenant RBAC;
      missing/expired/mismatched pool evidence fails closed. Existing per-tenant
      proofs remain an alternative; no application can manufacture either proof.
- [ ] Widget/frontend/demo preserve `/mediawidget`, public URLs include it, and
      widget health uses `/mediawidget/q/health`. Provisioner binds only loopback,
      denies business HTTP, has no Service, and passes its local Java exec probes.
      Read-only-root containers write only bounded `/media-runtime`, never relative
      `.uploads`; scratch must not hide application `/work`, `/app`, or `/opt/native-child`.
- [ ] The two shops share one service and use separate server-side credentials.
      Same filenames produce isolated images/jobs/logs. Forged headers, paths,
      cursors, tenant properties, credentials and cross-session Vaadin reconnects fail.
- [ ] Public image GET needs no login; imgproxy rejects unsigned/tampered transforms,
      upload/control sources, URL traversal, alternate accounts and metadata URLs.
      Anonymous direct image blob read works; container listing and uploads do not.
- [ ] Company OIDC validates the approved single-company issuer, audience,
      membership/role claim, PKCE/session/CSRF configuration and callback host.
      A valid token from a different company cannot register/manage tenants.
- [ ] REST receives only widget RS256 tokens with correct issuer/audience,
      tenant/scope/expiry/kid. It does not poll or run archive/coordinator schedules.
      Unrelated pods cannot reach REST or coordinator; no provisioner/archive ingress.
- [ ] Register an eligible tenant while archive replicas are zero; coordinator
      discovers work and KEDA activates without a Helm change or worker HTTP call.
      Test stale metrics, storage failures, initial startup, coordinator restart,
      positive fallback, cooldown and scale-down while an archive remains leased.
- [ ] Two worker replicas, cancellation/ETag races, lost leases and restarts do not
      duplicate output or resurrect cancelled work. Busy tenant A cannot starve B.
- [ ] Portal/provisioner outage does not block existing active tenants while
      projections remain reachable; projection outage/revocation fails closed,
      including established UI sessions. Record measured revocation bounds.
- [ ] Both approved browser origins pass Blob preflight, chunk upload and finalize;
      unapproved origins fail browser CORS. Browser network access exists without
      weakening upload ACLs. Shared origin/payload-limit policy is approved.
- [ ] A portal-only release leaves widget/worker/coordinator/imgproxy pod templates
      unchanged. Compatible mixed application versions read the projection.
- [ ] Deletion waits for matching-revision fresh drain ack, all grants expired,
      zero in-flight work, and explicit cache/retention proof. Absent/error evidence
      blocks deletion. Inventory snapshots/versions/soft-delete/legal holds.

## Operator-controlled migration (no automatic data changes)

1. Inventory current containers, active uploads/grants/workers, all blob counts,
   paths, lengths, hashes where available, content headers, tags, variants,
   `.jobs`/logs and public URL consumers. Capture ACL/CORS/cache/retention policy.
2. Register the original shop as an **explicit tenant** and record its immutable
   target containers, operation/schema/revision and access proofs. No default
   tenant or automatic adoption of legacy containers.
3. Announce/freeze writes and SAS issuance. Wait for the longest previously issued
   grant, then drain or deliberately cancel workers. Never run old/new writers
   simultaneously against the destination namespace.
4. Operator authors/reviews a copy/conversion manifest; copy images/variants and
   approved retained archives/history into assigned containers. Convert legacy job
   identities to UUID/schema 1. No generated migration command is executed here.
   **Retain source data unchanged**, including old metadata/job history.
5. Reconcile counts, lengths/checksums, headers and representative rendering.
   Verify no tenant A/B cross-namespace references. Record failures and rerun only
   reviewed idempotent manifest entries.
6. Validate the compatible chart/application/library set on disposable resources.
   Update each shop proxy's server-side credential, tenant binding, saved selection
   references and tenant-qualified public URLs. Confirm legacy routes are removed,
   not silently mapped to the original shop.
7. Verify both-shop management/public flows, rotation, isolation, scale-from-zero,
   deletion safety and observability before reopening writes/self-service. Obtain
   explicit sign-off for the pool-policy/attestation or per-tenant-proof operator gate.
8. Retain original data and manifest for the approved rollback window. Rollback
   after new writes is **not** a chart/image downgrade: pause writes, preserve and
   reconcile new tenant data and jobs, then forward-fix or explicitly reverse the
   reviewed migration. The single-tenant binary cannot serve newly registered tenants.
9. Source deletion, retained-version cleanup and cache purge require separate
   approvals after verification/rollback retention. No automated cleanup here.

Record owner, timestamp, environment, exact image artifacts, command/results,
evidence references, outstanding risks and approval for each gate. Do not mark
Azure/Kubernetes/browser scenarios passed solely from mocks or Helm rendering.
