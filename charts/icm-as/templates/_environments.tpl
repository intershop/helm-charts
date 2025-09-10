{{/* vim: set filetype=mustache: */}}

{{/*
Creates the environment section
*/}}
{{- define "icm-as.env" -}}
env:
- name: ENVIRONMENT
  value: "{{ include "icm-as.environmentName" . }}"
- name: INTERSHOP_EVENT_JGROUPSPROTOCOLSTACKCONFIGFILE
  value: "/intershop/jgroups-conf/jgroups-config.xml"
{{- if not (hasKey .Values.environment "SERVER_NAME") }}
- name: SERVER_NAME
  value: "{{ .Values.serverName }}"
{{- end }}
- name: IS_DBPREPARE
  value: "false"
- name: INTERSHOP_SERVER_NODE
  valueFrom:
    fieldRef:
      fieldPath: spec.nodeName
- name: INTERSHOP_SERVER_NAMESPACE
  valueFrom:
    fieldRef:
      fieldPath: metadata.namespace
- name: INTERSHOP_SERVER_PODNAME
  valueFrom:
    fieldRef:
      fieldPath: metadata.name
- name: INTERSHOP_SERVER_PODIP
  valueFrom:
    fieldRef:
      fieldPath: status.podIP
{{- if .Values.jvm.debug.enabled }}
- name: DEBUG_ICM
  value: "true"
{{- end }}
{{- if .Values.mssql.enabled }}
- name: INTERSHOP_DATABASETYPE
  value: mssql
- name: INTERSHOP_JDBC_URL
  value: {{ printf "jdbc:sqlserver://%s-mssql-service:1433;database=%s" (include "icm-as.fullname" .) .Values.mssql.databaseName }}
- name: INTERSHOP_JDBC_USER
  value: "{{ .Values.mssql.user }}"
{{ include "icm-as.envDatabasePassword" (list "INTERSHOP_JDBC_PASSWORD" .Values.mssql.passwordSecretKeyRef .Values.mssql.password) -}}
{{- else }}
- name: INTERSHOP_DATABASETYPE
  value: "{{ .Values.database.type | default "mssql" }}"
- name: INTERSHOP_JDBC_URL
  value: "{{ .Values.database.jdbcURL }}"
- name: INTERSHOP_JDBC_USER
  value: "{{ .Values.database.jdbcUser }}"
{{ include "icm-as.envDatabasePassword" (list "INTERSHOP_JDBC_PASSWORD" .Values.database.jdbcPasswordSecretKeyRef .Values.database.jdbcPassword) -}}
{{- end }}
{{ include "icm-as.envReplication" . }}
{{ include "icm-as.featuredJVMArguments" . }}
{{ include "icm-as.additionalJVMArguments" . }}
{{- range $key, $value := .Values.environment }}
{{ $environmentContainsSecret := false -}}
{{- /*
Nested loops on "secrets" and "secretsMounts" values lists are necessary due to limited functions on type lists.
No other reasonable possibility to get each dict within list "secrets"/"secretsMounts" values.
Purpose is to filter out any duplicated environment assignment when set both on "secrets"/"secretsMounts" and "environment".
*/}}
{{- range $secret := $.Values.secrets }}
{{- if eq $secret.env $key }}
{{ $environmentContainsSecret = true -}}
{{- end -}}
{{- end -}}
{{- range $mount := $.Values.secretsMounts }}
{{- if eq $mount.targetEnv $key }}
{{ $environmentContainsSecret = true -}}
{{- end -}}
{{- end -}}
{{- if not $environmentContainsSecret }}
- name: {{ $key }}
  value: {{ $value | quote }}
{{- end -}}
{{- end -}}
{{- if .Values.webLayer.enabled }}
- name: INTERSHOP_WEBADAPTER_ENABLED
  value: "false"
{{- end }}
{{- if .Values.webLayer.redis.enabled }}
- name: INTERSHOP_PAGECACHE_REDIS_ENABLED
  value: "true"
{{- end }}
{{- end -}}

{{/*
Creates the environment newrelic section
*/}}
{{- define "icm-as.envNewrelic" -}}
{{- if .Values.newrelic.enabled }}
- name: ENABLE_NEWRELIC
{{- if .Values.newrelic.apm.enabled }}
  value: "true"
{{- else }}
  value: "false"
{{- end }}
- name: NEW_RELIC_LICENSE_KEY
{{- /* licenseKeySecretKeyRef has precedence over license_key */ -}}
{{- if .Values.newrelic.licenseKeySecretKeyRef }}
  valueFrom:
    secretKeyRef:
{{- toYaml .Values.newrelic.licenseKeySecretKeyRef | nindent 6 }}
{{- else }}
  value: "{{ .Values.newrelic.license_key }}"
{{- end }}
{{- end }}
{{- end -}}

{{/*
Creates the environment secrets section
*/}}
{{- define "icm-as.envSecrets" -}}
{{- range $secret := .Values.secrets }}
- name: {{ $secret.env }}
  valueFrom:
    secretKeyRef:
      name: {{ $secret.name | quote }}
      key: {{ $secret.key | quote }}
{{- end -}}
{{- end -}}

{{/*
Creates the environment secretMounts section
*/}}
{{- define "icm-as.envSecretMounts" -}}
{{- $secretMountsRequireCertImport := false -}}
{{- range $index, $mount := .Values.secretMounts }}
{{- $type := default "secret" $mount.type }}
{{- $validTypes := list "secret" "certificate" }}
{{- if not (has $type $validTypes) }}
  {{- fail (printf "Error: invalid value '%s' at secretMounts[%d].type, must be one of (secret,certificate), default=secret." $type $index) -}}
{{- end -}}
{{- if $mount.targetEnv }}
- name: {{ $mount.targetEnv }}
  valueFrom:
    secretKeyRef:
      name: {{ $mount.secretName | quote }}
      key: {{ $mount.key | quote }}
{{- end -}}
{{- if and (eq $mount.type "certificate") ($mount.targetFile) }}
  {{- $secretMountsRequireCertImport = true -}}
{{- end -}}
{{- end -}} {{/*range $index, $mount := .Values.secretMounts*/}}
{{- if eq $secretMountsRequireCertImport true }}
- name: USE_SYSTEM_CA_CERTS
  value: "1"
{{- end -}} {{/*if eq $secretMountsRequireCertImport true*/}}
{{- end -}} {{/*define "icm-as.envSecretMounts"*/}}

{{/*
Creates the environment replication section
*/}}
{{- define "icm-as.envReplication" -}}
{{- if .Values.replication.enabled }}
- name: STAGING_SYSTEM_TYPE
  {{- if eq .Values.replication.role "source" }}
  value: editing
  {{- else }}
  value: live
  {{- end }}
{{/*
ICM-AS >= 12.2.0 supports new replication configuration via environments instead of replication-clusters.xml
ICM-AS >= 13.0.0 requires new replication configuration
*/}}
{{- $icmApplicationServerImageSemanticVersion := splitList "-" (include "icm-as.imageSemanticVersion" .) | first -}}
{{- $hasIcmApplicationServerImageSemanticVersion := regexMatch "^([0-9]+)\\.([0-9]+)\\.([0-9]+)$" $icmApplicationServerImageSemanticVersion -}}
{{- $hasNewReplicationConfigurationRequirement := and ($hasIcmApplicationServerImageSemanticVersion) (semverCompare ">= 13.0.0" $icmApplicationServerImageSemanticVersion) -}}
{{- $hasNewReplicationConfigurationSupport := and ($hasIcmApplicationServerImageSemanticVersion) (semverCompare ">= 12.2.0" $icmApplicationServerImageSemanticVersion) -}}
{{- $hasNewReplicationConfiguration := or (hasKey .Values.replication "source") (hasKey .Values.replication "targets") -}}
{{- if and ($hasNewReplicationConfigurationRequirement) (not $hasNewReplicationConfiguration) -}}
  {{- fail (printf "Error: Since ICM-AS 13.0.0 you need to use the new 'replication.source'/'replication.targets' configuration for replication, currently used '%s'." $icmApplicationServerImageSemanticVersion) -}}
{{- end -}}
{{- if and ($hasIcmApplicationServerImageSemanticVersion) (not $hasNewReplicationConfigurationSupport) ($hasNewReplicationConfiguration) -}}
  {{- fail (printf "Error: The new replication configuration 'replication.source'/'replication.targets' can be only used with ICM-AS 12.2.0 and newer, currently used '%s'." $icmApplicationServerImageSemanticVersion) -}}
{{- end -}}
{{- if and ($hasNewReplicationConfiguration) (hasKey .Values.replication.source "databaseLink") (hasKey .Values.replication.source "databaseName") -}}
  {{- fail "Error: Either mutual exclusive 'replication.source.databaseName' or 'replication.source.databaseLink' have to be configured, but not both." -}}
{{- end -}}
{{- if and (or (not $hasIcmApplicationServerImageSemanticVersion) $hasNewReplicationConfigurationSupport) $hasNewReplicationConfiguration }}
{{- $replicationSystemIDs := keys .Values.replication.targets | sortAlpha -}}
- name: STAGING_SYSTEMS_IDS
  value: {{ join "," $replicationSystemIDs | quote }}
{{- range $index, $replicationSystemID := $replicationSystemIDs }}
{{- if regexMatch ".*[._-].*" $replicationSystemID -}}
  {{- fail (printf "Error: The key '%s' in 'replication.targets' violates the constraint that it cannot contain any of these characters: '.', '-', '_'." $replicationSystemID) }}
{{- end -}}
{{- $replicationTarget := get $.Values.replication.targets $replicationSystemID -}}
{{- $replicationSystemIDEnvironmentKeyPrefix := printf "STAGING_SYSTEMS_%s" ($replicationSystemID | upper) }}
{{- if $.Values.replication.source.webserverUrl }}
- name: {{ $replicationSystemIDEnvironmentKeyPrefix }}_SOURCE_BASEURL
  value: {{ $.Values.replication.source.webserverUrl | quote }}
{{- end }}
{{- if $.Values.replication.source.databaseUser }}
- name: {{ $replicationSystemIDEnvironmentKeyPrefix }}_SOURCE_DATABASEUSER
  value: {{ $.Values.replication.source.databaseUser | quote }}
{{- end }}
{{- if $.Values.replication.source.databaseLink }}
- name: {{ $replicationSystemIDEnvironmentKeyPrefix }}_SOURCE_DATABASELINK
  value: {{ $.Values.replication.source.databaseLink | quote }}
{{- end }}
{{- if $.Values.replication.source.databaseName }}
- name: {{ $replicationSystemIDEnvironmentKeyPrefix }}_SOURCE_DATABASENAME
  value: {{ $.Values.replication.source.databaseName | quote }}
{{- end }}
{{- if $replicationTarget.webserverUrl }}
- name: {{ $replicationSystemIDEnvironmentKeyPrefix }}_TARGET_BASEURL
  value: {{ $replicationTarget.webserverUrl | quote }}
{{- end }}
{{- if $replicationTarget.databaseUser }}
- name: {{ $replicationSystemIDEnvironmentKeyPrefix }}_TARGET_DATABASEUSER
  value: {{ $replicationTarget.databaseUser | quote }}
{{- end }}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Job-specific-environment
*/}}
{{- define "icm-as.envJob" }}
{{- include "icm-as.env" . }}
- name: MAIN_CLASS
  value: "com.intershop.beehive.core.capi.job.JobServer"
- name: INTERSHOP_JOB_SERVER_EXCLUSIVE
  value: "true"
- name: INTERSHOP_SERVER_ASSIGNEDTOSERVERGROUP
  value: {{ .jobServerGroup }}
{{- include "icm-as.envNewrelic" . }}
{{- include "icm-as.envSecrets" . }}
{{- include "icm-as.envSecretMounts" . }}
{{- end -}}

{{/*
AppServer-specific-environment
*/}}
{{- define "icm-as.envAS" }}
{{- include "icm-as.env" . }}
{{- if .Values.job.enabled }}
- name: INTERSHOP_SERVER_ASSIGNEDTOSERVERGROUP
  value: "BOS,WFS"
{{- end }}
{{- include "icm-as.envNewrelic" . }}
{{- include "icm-as.envSecrets" . }}
{{- include "icm-as.envSecretMounts" . }}
{{- end -}}

{{/*
JDBC password env-entry (name+value)
expecting to get called like:
{{ include "icm-as.envDatabasePassword" (list "INTERSHOP_JDBC_PASSWORD" .Values.database.jdbcPasswordSecretKeyRef .Values.database.jdbcPassword) -}}
*/}}
{{- define "icm-as.envDatabasePassword" -}}
{{- $envName := index . 0 }}
{{- $secretKeyRef := index . 1 }}
{{- $plainPassword := index . 2 }}
{{- /* secretKeyRef has precedence over plainPassword */ -}}
- name: {{ $envName }}
{{- if $secretKeyRef }}
  {{- if not ($secretKeyRef.name) }}
    {{- fail "Error: missing value at database.jdbcPasswordSecretKeyRef.name" }}
  {{- end }}
  {{- if not ($secretKeyRef.key) }}
    {{- fail "Error: missing value at database.jdbcPasswordSecretKeyRef.key" }}
  {{- end }}
  valueFrom:
    secretKeyRef:
      name: {{ $secretKeyRef.name | quote }}
      key: {{ $secretKeyRef.key | quote }}
{{- else }}
  value: "{{ $plainPassword }}"
{{- end }}
{{- end -}}
