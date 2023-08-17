{{/* vim: set filetype=mustache: */}}

{{/*
Renders values from the operational context
*/}}

{{/* stagingType calculation differs from icm-as */}}
{{- define "icm-web.stagingType" -}}
  {{- include "icm-as.operationalContext" . -}}
  {{- .Values.operationalContext.stagingType | default "standalone" -}}
{{- end -}}

{{/*
Renders the operational context name
*/}}
{{- define "icm-web.operationalContextName" -}}
  {{- include "icm-as.operationalContext" . -}}
  {{- $customerId := .Values.operationalContext.customerId | default "n_a" -}}
  {{- $environmentType := include "icm-as.environmentType" . -}}
  {{- $environmentName := include "icm-as.environmentName" . -}}
  {{- $applicationType := include "icm-as.applicationType" . -}}
  {{/* stagingType calculation differs from icm-as */}}
  {{- $stagingType := include "icm-web.stagingType" . -}}
  {{- printf "%s-%s-%s-%s" $customerId $environmentName $applicationType $stagingType -}}
{{- end -}}
