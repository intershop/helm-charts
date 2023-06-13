{{/* vim: set filetype=mustache: */}}
{{/*
Creates the database environment section
*/}}
{{- define "icm-as.envDatabase" -}}
{{- if .Values.mssql.enabled -}}
- name: INTERSHOP_DATABASETYPE
  value: mssql
- name: INTERSHOP_JDBC_URL
  value: {{ printf "jdbc:sqlserver://%s-mssql-service:1433;database=%s" (include "icm-as.fullname" .) .Values.mssql.databaseName }}
- name: INTERSHOP_JDBC_USER
  value: "{{ .Values.mssql.user }}"
- name: INTERSHOP_JDBC_PASSWORD
  value: "{{ .Values.mssql.password }}"
{{- else -}}
- name: INTERSHOP_DATABASETYPE
  value: "{{ .Values.database.type }}"
- name: INTERSHOP_JDBC_URL
  value: "{{ .Values.database.jdbcURL }}"
- name: INTERSHOP_JDBC_USER
  value: "{{ .Values.database.jdbcUser }}"
- name: INTERSHOP_JDBC_PASSWORD
  value: "{{ .Values.database.jdbcPassword }}"
{{- end -}}
{{- end -}}