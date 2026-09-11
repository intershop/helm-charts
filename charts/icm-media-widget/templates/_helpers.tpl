{{- define "media.name" -}}
{{- default (printf "%s-%s" .Release.Name .Chart.Name) .Values.fullnameOverride | trunc 40 | trimSuffix "-" -}}
{{- end -}}

{{- define "media.component" -}}
{{- . | kebabcase -}}
{{- end -}}

{{- define "media.labels" -}}
app.kubernetes.io/name: icm-media-widget
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "media.restHost" -}}
{{- printf "%s-rest-interceptor.%s.svc.%s" (include "media.name" .) .Release.Namespace .Values.httpScaling.clusterDomain -}}
{{- end -}}

{{- define "media.workerUrl" -}}
{{- if .Values.httpScaling.rest.enabled -}}
{{- printf "http://%s:%d" (include "media.restHost" .) (int .Values.httpScaling.interceptor.port) -}}
{{- else -}}
{{- printf "http://%s-rest:8080" (include "media.name" .) -}}
{{- end -}}
{{- end -}}

{{- define "media.config" -}}
{{- $v := .root.Values -}}
{{- $role := .role -}}
{{- $name := include "media.name" .root -}}
QUARKUS_HTTP_HOST: {{ if eq $role "provisioner" }}"127.0.0.1"{{ else }}"0.0.0.0"{{ end }}
QUARKUS_HTTP_PORT: "8080"
QUARKUS_HTTP_ROOT_PATH: {{ if eq $role "widget" }}"/mediawidget"{{ else }}"/"{{ end }}
QUARKUS_HTTP_ACCESS_LOG_ENABLED: "false"
JAVA_TOOL_OPTIONS: "-Djava.io.tmpdir=/media-runtime"
QUARKUS_HTTP_BODY_UPLOADS_DIRECTORY: "/media-runtime/uploads"
TENANCY_CONTROL_ENDPOINT: {{ $v.azure.controlEndpoint | quote }}
TENANCY_DIRECTORY_TABLE: {{ $v.azure.directoryTable | quote }}
{{- if eq $role "widget" }}
TENANCY_CREDENTIALS_TABLE: {{ $v.azure.credentialsTable | quote }}
TENANCY_RUNTIME_TABLE: {{ $v.azure.runtimeTable | quote }}
TENANCY_MAX_UPLOAD_BYTES: {{ $v.upload.maxBytes | int64 | quote }}
TENANCY_MAX_OUTSTANDING_UPLOADS: {{ $v.upload.maxOutstanding | quote }}
TENANCY_UPLOAD_GRANT_SECONDS: {{ $v.upload.grantSeconds | quote }}
TENANCY_MAX_IMAGE_BYTES: {{ $v.worker.maxImageBytes | int64 | quote }}
TENANCY_MAX_IMAGE_REQUEST_BYTES: {{ $v.worker.maxImageRequestBytes | int64 | quote }}
QUARKUS_HTTP_LIMITS_MAX_BODY_SIZE: {{ $v.worker.maxImageRequestBytes | int64 | quote }}
TENANCY_MAX_IMAGE_DIMENSION: {{ $v.worker.maxImageDimension | int64 | quote }}
TENANCY_MAX_IMAGE_PIXELS: {{ $v.worker.maxImagePixels | int64 | quote }}
TENANCY_WORKER_TOKEN_ISSUER: {{ $v.jwt.issuer | quote }}
TENANCY_WORKER_TOKEN_AUDIENCE: {{ $v.jwt.audience | quote }}
SMALLRYE_JWT_SIGN_KEY_LOCATION: "/var/run/media-keys/signing.pem"
WORKER_SIGNING_KEY_LOCATION: "/var/run/media-keys/signing.pem"
TENANCY_WORKER_TOKEN_KEY_ID: {{ $v.jwt.keyId | quote }}
QUARKUS_REST_CLIENT_WORKER_CLIENT_URL: {{ include "media.workerUrl" .root | quote }}
WORKER_BASE_URL: {{ include "media.workerUrl" .root | quote }}
TENANCY_PUBLIC_BASE_URL: {{ printf "https://%s/mediawidget" $v.ingress.public.host | quote }}
TENANCY_IMGPROXY_BASE_URL: {{ printf "https://%s/imgproxy" $v.ingress.public.host | quote }}
TENANCY_MEDIA_ACCOUNT_ENDPOINT: {{ $v.azure.mediaEndpoint | quote }}
QUARKUS_HTTP_CORS_ENABLED: "false"
{{- else if has $role (list "archive" "rest" "coordinator") }}
MEDIA_ROLE: {{ $role | quote }}
TENANCY_RUNTIME_TABLE: {{ $v.azure.runtimeTable | quote }}
{{- if eq $role "coordinator" }}
TENANCY_DRAIN_TABLE: {{ $v.azure.drainTable | quote }}
{{- end }}
MEDIA_CONCURRENCY: {{ $v.worker.maxConcurrentJobs | quote }}
MEDIA_PER_TENANT_CONCURRENCY: {{ $v.worker.maxJobsPerTenant | quote }}
MEDIA_LOCAL_CONCURRENCY: {{ $v.worker.localConcurrency | quote }}
MEDIA_LOCAL_PER_TENANT_CONCURRENCY: {{ $v.worker.localPerTenantConcurrency | quote }}
MEDIA_MAX_ARCHIVE_BYTES: {{ $v.upload.maxBytes | int64 | quote }}
MEDIA_MAX_IMAGE_BYTES: {{ $v.worker.maxImageBytes | int64 | quote }}
MEDIA_MAX_IMAGE_OUTPUT_BYTES: {{ $v.worker.maxImageOutputBytes | int64 | quote }}
MEDIA_NATIVE_HEAP_MB: {{ $v.worker.nativeHeapMb | quote }}
MEDIA_NATIVE_ADDRESS_SPACE_BYTES: {{ $v.worker.nativeAddressSpaceBytes | int64 | quote }}
MEDIA_MAX_IMAGE_DIMENSION: {{ $v.worker.maxImageDimension | int64 | quote }}
MEDIA_MAX_ENTRIES: {{ $v.worker.maxArchiveEntries | int64 | quote }}
MEDIA_MAX_EXPANDED_BYTES: {{ $v.worker.maxExpandedBytes | int64 | quote }}
MEDIA_MAX_IMAGE_PIXELS: {{ $v.worker.maxImagePixels | int64 | quote }}
MEDIA_MAX_PROCESSING_SECONDS: {{ $v.worker.maxProcessingSeconds | int64 | quote }}
MEDIA_TENANTS_PER_POLL: {{ $v.worker.discoveryPageSize | quote }}
MEDIA_JOBS_PER_TENANT: {{ $v.worker.jobsPerTenantScan | quote }}
ARCHIVE_PROCESSING_INTERVAL: {{ printf "%ds" (int $v.worker.scanSeconds) | quote }}
MEDIA_COORDINATOR_INTERVAL: {{ printf "%ds" (int $v.worker.scanSeconds) | quote }}
MEDIA_METRICS_FRESHNESS_SECONDS: {{ $v.worker.metricsMaxAgeSeconds | quote }}
MEDIA_RETENTION_HOURS: {{ $v.worker.terminalRetentionHours | int64 | quote }}
{{- if eq $role "rest" }}
{{- if $v.httpScaling.rest.enabled }}
QUARKUS_SHUTDOWN_TIMEOUT: {{ printf "%ds" (int $v.httpScaling.rest.responseHeaderSeconds) | quote }}
{{- end }}
QUARKUS_HTTP_LIMITS_MAX_BODY_SIZE: {{ $v.worker.maxImageRequestBytes | int64 | quote }}
QUARKUS_HTTP_LIMITS_MAX_FORM_ATTRIBUTE_SIZE: {{ $v.worker.maxImageRequestBytes | int64 | quote }}
TENANCY_WORKER_TOKEN_ISSUER: {{ $v.jwt.issuer | quote }}
TENANCY_WORKER_TOKEN_AUDIENCE: {{ $v.jwt.audience | quote }}
MP_JWT_VERIFY_ISSUER: {{ $v.jwt.issuer | quote }}
MP_JWT_VERIFY_AUDIENCES: {{ $v.jwt.audience | quote }}
MP_JWT_VERIFY_PUBLICKEY_LOCATION: "/var/run/media-keys/verification.pem"
{{- end }}
{{- else }}
CONTROL_ROLE: {{ if eq $role "controlApi" }}"api"{{ else }}"provisioner"{{ end }}
QUARKUS_HTTP_AUTH_PERMISSION__HEALTH__PATHS: "/q/health,/q/health/*"
QUARKUS_HTTP_AUTH_PERMISSION__HEALTH__POLICY: "permit"
QUARKUS_HTTP_AUTH_PERMISSION__HEALTH__METHODS: "GET"
CONTROL_REGISTRY_ENDPOINT: {{ $v.azure.controlEndpoint | quote }}
CONTROL_REGISTRY_TABLE: {{ $v.azure.controlTable | quote }}
CONTROL_PROOFS_TABLE: {{ $v.azure.proofsTable | quote }}
CONTROL_DIRECTORY_TABLE: {{ $v.azure.directoryTable | quote }}
CONTROL_CREDENTIALS_TABLE: {{ $v.azure.credentialsTable | quote }}
{{- if eq $role "provisioner" }}
CONTROL_DRAIN_TABLE: {{ $v.azure.drainTable | quote }}
{{- end }}
CONTROL_MEDIA_ENDPOINT: {{ $v.azure.mediaEndpoint | quote }}
CONTROL_APPROVED_ORIGINS: {{ join "," $v.origins.approved | quote }}
CONTROL_CREDENTIAL_REFERENCE: {{ $v.azure.credentialReference | quote }}
CONTROL_INSTALLATION_ID: {{ $v.control.installationId | quote }}
CONTROL_MAX_TENANTS_PER_OWNER: {{ $v.control.maxTenantsPerOwner | quote }}
CONTROL_MAX_CREDENTIALS_PER_TENANT: {{ $v.control.maxCredentialsPerTenant | quote }}
CONTROL_MAX_ORIGINS_PER_TENANT: {{ $v.control.maxOriginsPerTenant | quote }}
CONTROL_MAX_ATTEMPTS: {{ $v.control.maxAttempts | quote }}
CONTROL_DRAIN_MAX_AGE_SECONDS: {{ $v.control.drainMaxAgeSeconds | quote }}
CONTROL_MAX_GRANT_SECONDS: {{ $v.upload.grantSeconds | quote }}
CONTROL_MAX_TENANTS_PER_SWEEP: {{ $v.control.maxTenantsPerSweep | quote }}
{{- if eq $role "controlApi" }}
CONTROL_PUBLIC_ORIGIN: {{ printf "https://%s" $v.ingress.control.host | quote }}
CONTROL_MEMBER_ROLE: {{ $v.control.memberRole | quote }}
CONTROL_OPERATOR_ROLE: {{ $v.control.operatorRole | quote }}
QUARKUS_OIDC_AUTH_SERVER_URL: {{ $v.oidc.issuer | quote }}
QUARKUS_OIDC_TOKEN_ISSUER: {{ $v.oidc.issuer | quote }}
QUARKUS_OIDC_CLIENT_ID: {{ $v.oidc.clientId | quote }}
QUARKUS_OIDC_APPLICATION_TYPE: "web-app"
QUARKUS_OIDC_TOKEN_AUDIENCE: {{ $v.oidc.audience | quote }}
QUARKUS_OIDC_ROLES_ROLE_CLAIM_PATH: {{ $v.oidc.rolesClaim | quote }}
QUARKUS_OIDC_AUTHENTICATION_FORCE_REDIRECT_HTTPS_SCHEME: "true"
{{- else }}
QUARKUS_PROFILE: "provisioner"
QUARKUS_HTTP_AUTH_PERMISSION__APPLICATION__PATHS: "/*"
QUARKUS_HTTP_AUTH_PERMISSION__APPLICATION__POLICY: "deny"
QUARKUS_OIDC_ENABLED: "false"
QUARKUS_OIDC_TENANT_ENABLED: "false"
QUARKUS_OIDC_AUTH_SERVER_URL: ""
QUARKUS_OIDC_CLIENT_ID: ""
QUARKUS_OIDC_CREDENTIALS_SECRET: ""
QUARKUS_OIDC_TOKEN_ISSUER: ""
QUARKUS_OIDC_TOKEN_AUDIENCE: ""
QUARKUS_OIDC_TOKEN_STATE_MANAGER_ENCRYPTION_SECRET: ""
{{- end }}
{{- end }}
{{- end -}}

{{- define "media.secretEnv" -}}
{{- range $name, $ref := . }}
- name: {{ $name }}
  valueFrom:
    secretKeyRef:
      name: {{ $ref.name | quote }}
      key: {{ $ref.key | quote }}
{{- end }}
{{- end -}}
