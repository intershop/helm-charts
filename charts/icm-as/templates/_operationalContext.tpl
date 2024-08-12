{{/* vim: set filetype=mustache: */}}

{{/*
Renders values from the operational context
*/}}

{{- define "icm-as.operationalContext" -}}
  {{- if not .Values.operationalContext -}}
    {{- $_ := set .Values "operationalContext" dict -}}
  {{- end -}}
{{- end -}}

{{- define "icm-as.environmentType" -}}
  {{- include "icm-as.operationalContext" . -}}
  {{- .Values.operationalContext.environmentType | default "prd" -}}
{{- end -}}

{{- define "icm-as.environmentName" -}}
  {{- include "icm-as.operationalContext" . -}}
  {{- .Values.operationalContext.environmentName | default (include "icm-as.environmentType" .) -}}
{{- end -}}

{{- define "icm-as.stagingType" -}}
  {{- include "icm-as.operationalContext" . -}}
  {{- if .Values.replication.enabled -}}
    {{- if eq .Values.replication.role "source" -}}
      {{- $_ := set .Values.operationalContext "stagingType" "edit" -}}
    {{- else -}}
      {{- $_ := set .Values.operationalContext "stagingType" "live" -}}
    {{- end -}}
  {{- else -}}
    {{- .Values.operationalContext.stagingType | default "standalone" -}}
  {{- end -}}
{{- end -}}

{{/*
Renders the operational context name
*/}}
{{- define "icm-as.operationalContextName" -}}
  {{- include "icm-as.operationalContext" . -}}
  {{- $customerId := .Values.operationalContext.customerId | default "n_a" -}}
  {{- $environmentName := include "icm-as.environmentName" . -}}
  {{- $stagingType := include "icm-as.stagingType" . -}}
  {{- printf "%s-%s-%s" $customerId $environmentName $stagingType -}}
{{- end -}}
