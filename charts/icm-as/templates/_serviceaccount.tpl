{{/* vim: set filetype=mustache: */}}

{{/*
Check if service account is enabled
*/}}
{{- define "icm-as.serviceAccount.enabled" -}}
{{- or .Values.serviceAccount.create .Values.workloadIdentity.enabled (eq (include "icm-as.jgroups.discovery" .) "kube_ping") -}}
{{- end -}}{{/* define "icm-as.serviceAccount.enabled" */}}

{{/*
Renders the pod labels related to service account
*/}}
{{- define "icm-as.serviceAccount.podLabels" -}}
  {{- if eq (include "icm-as.serviceAccount.enabled" .) "true" -}}
  azure.workload.identity/use: "true"
  {{- end -}}
{{- end -}}{{/* define "icm-as.serviceAccount.podLabels" */}}

{{/*
Renders the pod spec related to service account
*/}}
{{- define "icm-as.serviceAccount.podSpec" -}}
  {{- if eq (include "icm-as.serviceAccount.enabled" .) "true" -}}
  serviceAccountName: {{ include "icm-as.serviceAccount.name" . }}
  {{- end -}}
{{- end -}}{{/* define "icm-as.serviceAccount.podSpec" */}}


{{/*
Create the name of the service account
*/}}
{{- define "icm-as.serviceAccount.name" -}}
  {{- default (print (include "icm-as.fullname" .) "-sa") .Values.serviceAccount.name -}}
{{- end -}}{{/* define "icm-as.serviceAccount.name" */}}
