{{/* vim: set filetype=mustache: */}}
{{/*
Creates the environment section
*/}}
{{- define "icm-as.env" }}
env:
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
{{- if .Values.datadog.enabled }}
- name: ENABLE_DATADOG
  value: "true"
- name: DD_ENV
  valueFrom:
    fieldRef:
      fieldPath: metadata.labels['tags.datadoghq.com/env']
- name: DD_SERVICE
  valueFrom:
    fieldRef:
      fieldPath: metadata.labels['tags.datadoghq.com/service']
- name: DD_VERSION
  valueFrom:
    fieldRef:
      fieldPath: metadata.labels['tags.datadoghq.com/version']
- name: DD_LOGS_INJECTION
  value: "true"
- name: DD_AGENT_HOST
  valueFrom:
    fieldRef:
      fieldPath: status.hostIP
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
{{ include "icm-as.featuredJVMArguments" . }}
{{ include "icm-as.additionalJVMArguments" . }}
{{- range $key, $value := .Values.environment }}
- name: {{ $key }}
  value: {{ $value | quote }}
{{- end -}}
{{- end -}}