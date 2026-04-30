{{/* vim: set filetype=mustache: */}}

{{/*
Renders values from the operational context
*/}}

{{- define "icm-web.operationalContext" -}}
  {{- if not .Values.operationalContext -}}
    {{- $_ := set .Values "operationalContext" dict -}}
  {{- end -}}
{{- end -}}

{{- define "icm-web.environmentType" -}}
  {{- include "icm-web.operationalContext" . -}}
  {{- .Values.operationalContext.environmentType | default "prd" -}}
{{- end -}}

{{- define "icm-web.environmentName" -}}
  {{- include "icm-web.operationalContext" . -}}
  {{- .Values.operationalContext.environmentName | default (include "icm-web.environmentType" .) -}}
{{- end -}}

{{- define "icm-web.stagingType" -}}
  {{- include "icm-web.operationalContext" . -}}
  {{- .Values.operationalContext.stagingType | default "standalone" -}}
{{- end -}}

{{- define "icm-web.customerId" -}}
  {{- include "icm-web.operationalContext" . -}}
  {{- .Values.operationalContext.customerId | default "n_a" -}}
{{- end -}}

{{/*
Renders the operational context name
*/}}
{{- define "icm-web.operationalContextName" -}}
  {{- include "icm-web.operationalContext" . -}}
  {{- $customerId := include "icm-web.customerId" . -}}
  {{- $environmentName := include "icm-web.environmentName" . -}}
  {{- $stagingType := include "icm-web.stagingType" . -}}
  {{- printf "%s-%s-%s" $customerId $environmentName $stagingType -}}
{{- end -}}
