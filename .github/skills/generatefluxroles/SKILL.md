---
name: generatefluxroles
description: 'Update the least-privilege Flux CD RBAC ClusterRole definitions (cluster-roles/cr-<app>-flux.yaml) for pwa, icm, or iom by merging the current state of the corresponding Helm chart(s) into the existing ClusterRole rules, never removing previously granted permissions.'
disable-model-invocation: true
argument-hint: '[pwa|icm|iom|all]'
---

# Generate Flux RBAC ClusterRoles

Update one or more `cr-<app>-flux.yaml` files in the `cluster-roles/` directory.
Each file is a Kubernetes `ClusterRole` that restricts the ServiceAccount used by
Flux CD (`helm-controller`, via `HelmRelease.spec.serviceAccountName` /
impersonation) to only the resource kinds that the corresponding Helm chart(s)
can create, update or delete during install/upgrade. Existing rules are merged,
not replaced, so older chart releases can still roll out (see section 4).

Existing reference files (update in place, preserving this style):

- [cr-pwa-flux.yaml](../../../cluster-roles/cr-pwa-flux.yaml)
- [cr-icm-flux.yaml](../../../cluster-roles/cr-icm-flux.yaml)
- [cr-iom-flux.yaml](../../../cluster-roles/cr-iom-flux.yaml)

## 1. Determine the target application

Parse the argument passed after the slash command. Valid values (case
insensitive): `pwa`, `icm`, `iom`, `all`.

If no argument is given, or it doesn't match one of these values, ask the user
which application(s) to update before doing anything else - offer exactly
these four choices: `pwa`, `icm`, `iom`, `all`.

## 2. Conventions that apply to every role (non-negotiable)

- **Kind**: Always `ClusterRole`, never `Role`. Never include a `namespace`
  field. The header comment must explain that namespace isolation is achieved
  by binding this ClusterRole via a **namespaced** `RoleBinding` (not a
  `ClusterRoleBinding`) in each release namespace, and show the
  `roleRef.kind: ClusterRole` / `roleRef.name: flux-<app>` snippet.
- **Naming**: `metadata.name: flux-<app>` (`flux-pwa`, `flux-icm`, `flux-iom`).
  Output file: `cluster-roles/cr-<app>-flux.yaml` (the `cr-` prefix signals
  this manifest defines a `ClusterRole`).
- **Discovery**: Enumerate resource kinds by searching for `^kind:` across
  `charts/<chart>/templates/**` for every relevant chart, including nested
  subcharts under `charts/<chart>/charts/**`. Subcharts may be vendored as
  plain directories (inspect directly) or as packaged `.tgz` archives
  (list/extract with `tar tzf` / `tar xzf` into a scratch dir, e.g. `/tmp`, to
  inspect their templates - do not commit extracted files). If `.tgz` archives
  look stale, run `helm dependency update` in that chart's directory first.
- **Rule shape**: Group rules by `apiGroup`, one rule per group listing every
  resource kind found for it, with `verbs: [get, list, watch, create, update,
patch, delete]` for anything the chart creates/manages. Add a comment above
  each rule naming the template file(s) it came from.
- **Formatting**: Generated or modified YAML files must comply with the repository's
  Prettier configuration in [.prettierrc](../../../.prettierrc) (e.g. `singleQuote: true`,
  `tabWidth: 2`, `printWidth: 120`, and `endOfLine: lf`). Any quoted YAML strings
  (such as `apiGroups: ['']`) must use single quotes rather than double quotes.
  When changes are made, ensure the file is formatted according to Prettier
  (`npx prettier --write cluster-roles/cr-<app>-flux.yaml`).
- **Always add, even if not directly templated**:
  - Core `secrets`, full CRUD - required because Helm 3 stores release
    history as Secrets (`sh.helm.release.v1.<release>.v<revision>`) in the
    release namespace, regardless of whether the chart itself templates a
    Secret.
  - Read-only `pods` (get/list/watch) and `pods/log` (get) - for `--wait`
    readiness checks and fetching logs of failed hook/job Pods.
  - Read-only `events` (get/list/watch) - for troubleshooting transient
    objects created during install/upgrade.
- **Helm hooks**: Resources annotated with `helm.sh/hook` (e.g. a
  ServiceAccount/Role/RoleBinding/Job created for a post-upgrade hook) need
  full CRUD **including delete**, since
  `helm.sh/hook-delete-policy: before-hook-creation,hook-succeeded` (or
  similar) causes them to be deleted and recreated on every run.
- **Cluster-scoped resources are excluded from rules entirely.** A namespaced
  `RoleBinding` cannot grant access to non-namespaced resources no matter what
  the bound `ClusterRole` contains (Kubernetes RBAC only honors cluster-scoped
  rules via a `ClusterRoleBinding`). Never add rules for `StorageClass`,
  `PersistentVolume`, `ClusterRole`, `ClusterRoleBinding`, `Namespace`,
  `IngressClass`, `PodSecurityPolicy`, `CustomResourceDefinition`, etc. Instead
  document in the header comment exactly which chart values/features trigger
  such objects, and recommend either out-of-band cluster-admin provisioning or
  switching values to avoid them (e.g. persistence provisioning `static`/
  `dynamic` instead of `local`/`nfs`/`cluster`).

## 3. Application-specific conventions

### pwa (`charts/pwa`)

Single chart, no subcharts.

- Always include `autoscaling/horizontalpodautoscalers`, full CRUD, **even
  though the chart does not template one**. pwa releases are conventionally
  paired with an externally managed HorizontalPodAutoscaler targeting the main
  Deployment; note this explicitly in the header comment as a non-chart-native
  addition.
- Known Helm hook: `templates/job_cache-reset.yaml` (ServiceAccount, Role,
  RoleBinding, Job - post-upgrade cache-reset hook).

### icm (`charts/icm`, umbrella chart)

Dependencies are declared in `charts/icm/Chart.yaml`:
`icm-as` (always installed), `icm-web` (condition `icm-web.enabled`, default
`true`), `ingress-haproxy`/`kubernetes-ingress`, `mailhog`, `redis`,
`redis-cluster` (all condition-gated, default `false`). Check
`charts/icm/values.yaml` for the current defaults before classifying a
dependency's resources as core vs. optional in comments.

Inspect `charts/icm-as/templates/**`, `charts/icm-web/templates/**`, and the
packaged subcharts under `charts/icm/charts/*.tgz`.

- **Exclude the entire `kubernetes-ingress` (haproxy) dependency.** It deploys
  shared, cluster-scoped ingress-controller infrastructure (`ClusterRole`,
  `ClusterRoleBinding`, `Namespace`, `IngressClass`, `PodSecurityPolicy`,
  optional `ServiceMonitor`/`PodMonitor` CRDs). Document that it must never be
  installed through a namespace-isolated per-app release and should be
  deployed as separate, shared cluster infrastructure instead.
- Include `batch.core.intershop.de/icmjobs` (the `ICMJob` custom resource used
  by icm-as job servers), full CRUD. Note that its CRD and controller
  (`charts/icm-job`, `ClusterRole icm-manager-role`, etc.) are a separate,
  cluster-scoped bootstrap concern that must already exist - this Role only
  grants rights over `icmjobs` objects, not the controller.
- Always include `batch/cronjobs` (full CRUD) alongside `batch/jobs`, for
  icm-specific scheduled rollouts (e.g. periodic maintenance/restart jobs
  managed alongside icm releases) - this is not tied to a specific chart
  template and should be granted unconditionally for the icm role.
- If `redis`/`redis-cluster` (Bitnami) are in scope, they additionally need:
  `apps/statefulsets`, `policy/poddisruptionbudgets`,
  `autoscaling/horizontalpodautoscalers`, `networking.k8s.io/networkpolicies`,
  namespaced `rbac.authorization.k8s.io/roles`+`rolebindings` (never
  `clusterroles`/`clusterrolebindings`), and `batch/jobs` (redis-cluster's
  `update-cluster.yaml` resize hook). Optionally add
  `monitoring.coreos.com/servicemonitors`+`prometheusrules` only if metrics
  are enabled and the Prometheus Operator CRDs are expected on-cluster.
  Exclude their optional `PodSecurityPolicy` templates (cluster-scoped,
  deprecated on modern Kubernetes).
- icm-as's `jgroups` `kube_ping` discovery mode
  (`templates/jgroups-kubeping-cr.yaml` / `-crb.yaml`) creates a static-named,
  cluster-scoped `ClusterRole jgroups-kubeping-pod-reader` +
  `ClusterRoleBinding`. Exclude from rules and document that a cluster admin
  must provision this once, cluster-wide, outside any per-namespace release.

### iom (`charts/iom`)

Dependencies are declared in `charts/iom/Chart.yaml`: `mailpit` (remote chart,
not vendored locally, condition `mailpit.enabled`, default `false`),
`iom-tests` (condition `iom-tests.enabled`, default `false`, local dir
`charts/iom/charts/iom-tests`), `postgres` (condition `postgres.enabled`,
default `false`, local dir `charts/iom/charts/postgres`).

Inspect `charts/iom/templates/**`, `charts/iom/charts/iom-tests/templates/**`,
`charts/iom/charts/postgres/templates/**`. For `mailpit` (not vendored),
either run `helm dependency update` to fetch and inspect it, or assume its
conventional namespaced kinds (Deployment, Service, Ingress, Secret) are
already covered by the base rule set.

- Known Helm hook: `templates/patch-downtime.yaml` (ServiceAccount, Role,
  RoleBinding, Job - post-install/post-upgrade hook, only rendered when
  `.Values.downtime` is true and `replicaCount != 1`).
- Exclude the cluster-scoped `StorageClass`/`PersistentVolume` created by
  `templates/persistenceLocal.yaml` (and the postgres subchart's equivalent)
  when `persistence.provisioning: local`. Recommend `static` or `dynamic`
  provisioning for namespace-isolated GitOps releases.

## 4. Execution steps

1. Resolve the target application(s) per step 1.
2. For each target, re-run the discovery/inspection steps (do not rely on
   memory of previous conversations - charts may have changed) and build the
   current resource-kind inventory, applying the conventions in sections 2 and 3.
3. Read the existing `cluster-roles/cr-<app>-flux.yaml` (if present). If it does
   not exist, create it from the inventory alone. Otherwise, compare the inventory
   against the existing rules:
   - **No-op check (strict)**: If no functional modifications, additions, or fixes
     to the rules are required (i.e. all required apiGroups, resources, and verbs
     are already fully covered and no functional changes are needed), the agent
     **MUST NOT** modify the file. Do **NOT** rewrite, reformat, polish, or attempt
     to improve documentation, comments, or header text. Leave the file untouched
     and inform the user that everything is up to date.
   - If functional modifications / additions / fixes **are** required, merge the
     inventory into the existing rules as described below and write the result back
     to the same file, preserving the established header-comment structure: purpose
     statement, ClusterRole + namespaced-RoleBinding usage snippet,
     resource-kind-to-template mapping, and a clearly marked section documenting
     cluster-scoped exclusions and the reasoning/workarounds for each. Format the
     resulting manifest according to [.prettierrc](../../../.prettierrc) (notably `singleQuote: true`).
4. Merge rules (non-negotiable, backwards compatibility):
   - **Never remove** an existing `apiGroup` / resource / verb grant. If the chart
     no longer creates or manages a resource (or a verb is no longer needed), keep
     the grant anyway so that older chart releases that still use it are not
     blocked.
   - **Add** any apiGroup or resource found by discovery that is missing from the
     file, with the verbs listed in section 2.
   - **Widen** verbs for resources already present: the result is the union of
     existing and newly required verbs for each apiGroup + resource pair.
   - **Retained grants** that no longer map to a template must be annotated with a
     comment such as `# retained: no longer templated, kept for older releases`,
     and the header's resource-kind-to-template mapping must mark them the same way.
   - **Pruning is only allowed when the user explicitly asks for it.** Do not
     remove rules, resources or verbs on your own initiative.
   - If the existing file contains a cluster-scoped rule (see section 2), keep it
     unchanged but flag it in the summary; do not add new cluster-scoped rules.
5. Report the outcome:
   - If no changes were required for a file, state clearly that the file is up to date and was left unmodified.
   - For each updated file, report a brief summary listing: rules added, verbs widened, grants retained although no longer templated, and any flagged cluster-scoped entries.
