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
  value: "{{ .Values.database.type }}"
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
Nested loop on "secrets" values list necessary due to limited functions on type lists.
No other reasonable possibility to get each dict within list "secrets" values.
Purpose is to filter out any duplicated environment assignment when set both on "secrets" and "environment".
*/}}
{{- range $secret := $.Values.secrets }}
{{- if eq $secret.env $key }}
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
- name: STAGING_PROCESS_CLASSIC
  value: {{ .Values.replication.classic | quote}}
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
{{- include "icm-as.envSecrets" . }}
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
{{- include "icm-as.envSecrets" . }}
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
  valueFrom:
    secretKeyRef:
{{- toYaml $secretKeyRef | nindent 6 }}
{{- else }}
  value: "{{ $plainPassword }}"
{{- end }}
{{- end -}}
