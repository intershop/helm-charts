{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "intershop-pwa.name" -}}
{{- default .Chart.Name .Values.pwa_ssr.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "pwa_nginx.name" -}}
{{- default "nginx" .Values.pwa_nginx.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "intershop-pwa.fullname" -}}
{{- if .Values.pwa_ssr.fullnameOverride -}}
{{- .Values.pwa_ssr.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.pwa_ssr.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "pwa_nginx.fullname" -}}
{{- if .Values.pwa_nginx.fullnameOverride -}}
{{- .Values.pwa_nginx.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "nginx" .Values.pwa_nginx.nameOverride -}}
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
{{- define "intershop-pwa.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "intershop-pwa.labels" -}}
helm.sh/chart: {{ include "intershop-pwa.chart" . }}
{{ include "intershop-pwa.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "pwa_nginx.labels" -}}
helm.sh/chart: {{ include "intershop-pwa.chart" . }}
{{ include "pwa_nginx.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "pwa_nginx.selectorLabels" -}}
app.kubernetes.io/name: {{ include "pwa_nginx.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}


{{/*
Selector labels
*/}}
{{- define "intershop-pwa.selectorLabels" -}}
app.kubernetes.io/name: {{ include "intershop-pwa.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

