{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "icm-web.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "icm-web.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "icm-web.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "icm-web.labels" -}}
{{- $root := .root | default . -}}
helm.sh/chart: {{ include "icm-web.chart" $root }}
environment-name: "{{ include "icm-web.environmentName" $root }}"
environment-type: "{{ include "icm-web.environmentType" $root }}"
operational-context: {{ include "icm-web.operationalContextName" $root }}
{{ include "icm-web.selectorLabels" . }}
app.kubernetes.io/version: {{ $root.Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ $root.Release.Service }}
{{- end -}}

{{/*
Selector labels (component optional)
*/}}
{{- define "icm-web.selectorLabels" -}}
{{- $root := .root | default . -}}
app.kubernetes.io/name: {{ include "icm-web.name" $root }}
app.kubernetes.io/instance: {{ $root.Release.Name }}
{{- /* component: prefer .component, fallback to .Values.component */ -}}
{{- $component := "" -}}
{{- if hasKey . "component" -}}
  {{- $component = .component -}}
{{- else if and (hasKey $root.Values "component") $root.Values.component -}}
  {{- $component = $root.Values.component -}}
{{- end -}}
{{- if $component }}
app.kubernetes.io/component: {{ $component }}
{{- end }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "icm-web.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "icm-web.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}
