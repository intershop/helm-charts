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
- name: INTERSHOP_JDBC_PASSWORD
{{- /* passwordSecretKeyRef has precedence over password */ -}}
{{- if .Values.mssql.passwordSecretKeyRef }}
  valueFrom:
    secretKeyRef:
{{- toYaml .Values.mssql.passwordSecretKeyRef | nindent 6 }}
{{- else }}
  value: "{{ .Values.mssql.password }}"
{{- end }}
{{- else }}
- name: INTERSHOP_DATABASETYPE
  value: "{{ .Values.database.type }}"
- name: INTERSHOP_JDBC_URL
  value: "{{ .Values.database.jdbcURL }}"
- name: INTERSHOP_JDBC_USER
  value: "{{ .Values.database.jdbcUser }}"
- name: INTERSHOP_JDBC_PASSWORD
{{- /* jdbcPasswordSecretKeyRef has precedence over jdbcPassword */ -}}
{{- if .Values.database.jdbcPasswordSecretKeyRef }}
  valueFrom:
    secretKeyRef:
{{- toYaml .Values.database.jdbcPasswordSecretKeyRef | nindent 6 }}
{{- else }}
  value: "{{ .Values.database.jdbcPassword }}"
{{- end }}
{{- end }}
{{- if .Values.replication.enabled }}
- name: STAGING_SYSTEM_TYPE
  {{- if eq .Values.replication.role "source" }}
  value: editing
  {{- else }}
  value: live
  {{- end }}
{{- end }}
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
