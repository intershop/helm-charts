{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "pwa-main.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "pwa-main.fullname" -}}
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
Create a name to refer to ICM Web Adapter service needed for hybrid mode.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "pwa-main.hybridname" -}}
{{- $name := default "icm-web" .Values.hybrid.backend.service -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "pwa-main.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
    ingress configuration
*/}}
{{- define "pwa-ingress.service" -}}
{{- if .Values.cache.enabled -}}
{{- printf "%s" (include  "pwa-cache.fullname" . ) -}}
{{- else -}}
{{- printf "%s" (include  "pwa-main.fullname" . ) -}}
{{- end -}}
{{- end -}}

{{/*
pwa cache variables
*/}}
{{- define "pwa-cache.fullname" -}}
{{- printf "%s-%s" (include  "pwa-main.fullname" . ) "cache" -}}
{{- end -}}

{{- define "pwa-cache.name" -}}
{{- printf "%s-%s" (include  "pwa-main.name" . ) "cache" -}}
{{- end -}}

{{/*
pwa channels configuration
- required for the pwa cache
*/}}
{{- define "pwa-channels.fullname" -}}
{{- printf "%s-%s" (include  "pwa-main.fullname" . ) "channels" -}}
{{- end -}}

{{- define "pwa-channels.name" -}}
{{- printf "%s-%s" (include  "pwa-main.name" . ) "channels" -}}
{{- end -}}

{{/*
*/}}
{{- define "pwa-prefetch.jobname" -}}
{{- printf "%s-%s-%s" (include  "pwa-main.fullname" .context ) "prefect" (sha1sum .host) -}}
{{- end -}}

{{/*
*/}}
{{- define "pwa-prefetch.url" -}}
{{- printf "%s://%s%s" (default "https" .proto) .host (default "/" .path) -}}
{{- end -}}