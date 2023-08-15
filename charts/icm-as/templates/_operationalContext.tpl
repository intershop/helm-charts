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

{{- define "icm-as.applicationType" -}}
  {{- include "icm-as.operationalContext" . -}}
  {{- .Values.operationalContext.applicationType | default "icm" -}}
{{- end -}}

{{/*
Renders the operational context name
*/}}
{{- define "icm-as.operationalContextName" -}}
  {{- include "icm-as.operationalContext" . -}}
  {{- $customerId := .Values.operationalContext.customerId | default "n_a" -}}
  {{- $environmentType := include "icm-as.environmentType" . -}}
  {{- $environmentName := include "icm-as.environmentName" . -}}
  {{- $applicationType := include "icm-as.applicationType" . -}}
  {{/* stagingType calculation differs from icm-web */}}
  {{- $_ := set .Values.operationalContext "stagingType" "standalone" -}}
  {{- if .Values.replication.enabled -}}
    {{- if eq .Values.replication.role "source" -}}
      {{- $_ := set .Values.operationalContext "stagingType" "edit" -}}
    {{- else -}}
      {{- $_ := set .Values.operationalContext "stagingType" "life" -}}
    {{- end -}}
  {{- end -}}
  {{- printf "%s-%s-%s-%s" $customerId $environmentName $applicationType .Values.operationalContext.stagingType -}}
{{- end -}}
