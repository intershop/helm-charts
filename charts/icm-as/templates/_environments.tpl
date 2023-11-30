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
{{- end }}
{{- if .Values.mssql.enabled }}
- name: INTERSHOP_DATABASETYPE
  value: mssql
- name: INTERSHOP_JDBC_URL
  value: {{ printf "jdbc:sqlserver://%s-mssql-service:1433;database=%s" (include "icm-as.fullname" .) .Values.mssql.databaseName }}
- name: INTERSHOP_JDBC_USER
  value: "{{ .Values.mssql.user }}"
- name: INTERSHOP_JDBC_PASSWORD
  value: "{{ .Values.mssql.password }}"
{{- else }}
- name: INTERSHOP_DATABASETYPE
  value: "{{ .Values.database.type }}"
- name: INTERSHOP_JDBC_URL
  value: "{{ .Values.database.jdbcURL }}"
- name: INTERSHOP_JDBC_USER
  value: "{{ .Values.database.jdbcUser }}"
- name: INTERSHOP_JDBC_PASSWORD
  value: "{{ .Values.database.jdbcPassword }}"
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
- name: {{ $key }}
  value: {{ $value | quote }}
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
{{- end -}}

{{/*
AppServer-specific-environment
*/}}
{{- define "icm-as.envAS" }}
{{- include "icm-as.env" . }}
{{- if .Values.job.enabled }}
- name: INTERSHOP_SERVER_ASSIGNEDTOSERVERGROUP
  value: "BOS,WSF"
{{- end }}
{{- end -}}
