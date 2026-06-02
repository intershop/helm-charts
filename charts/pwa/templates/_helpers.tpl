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
Create chart name and version as used by the chart label.
*/}}
{{- define "pwa-main.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
pwa pod anti affinity
*/}}
{{- define "pwa-main.podAntiAffinity" -}}
{{- if .Values.podAntiAffinity.enabled -}}
podAntiAffinity:
  {{- if .Values.podAntiAffinity.required }}
  requiredDuringSchedulingIgnoredDuringExecution:
    - topologyKey: "kubernetes.io/hostname"
      labelSelector:
        matchLabels:
          app.kubernetes.io/name: {{ include "pwa-main.name" . }}
          app.kubernetes.io/instance: {{ .Release.Name }}
          {{- if .Values.podLabels }}
          {{- toYaml .Values.podLabels | nindent 10 }}
          {{- end }}
  {{- else }}
  preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      podAffinityTerm:
        topologyKey: "kubernetes.io/hostname"
        labelSelector:
          matchLabels:
            app.kubernetes.io/name: {{ include "pwa-main.name" . }}
            app.kubernetes.io/instance: {{ .Release.Name }}
            {{- if .Values.podLabels }}
            {{- toYaml .Values.podLabels | nindent 12 }}
            {{- end }}
  {{- end }}
{{- end -}}
{{- end -}}

{{/*
    ingress configuration
*/}}
{{- define "pwa-ingress.service" -}}
{{- printf "%s" (include  "pwa-cache.fullname" . ) -}}
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
pwa cache pod anti affinity
*/}}
{{- define "pwa-cache.podAntiAffinity" -}}
{{- if .Values.cache.podAntiAffinity.enabled -}}
podAntiAffinity:
  {{- if .Values.cache.podAntiAffinity.required }}
  requiredDuringSchedulingIgnoredDuringExecution:
    - topologyKey: "kubernetes.io/hostname"
      labelSelector:
        matchLabels:
          app.kubernetes.io/name: {{ include "pwa-cache.name" . }}
          app.kubernetes.io/instance: {{ .Release.Name }}
          {{- if .Values.cache.podLabels }}
          {{- toYaml .Values.cache.podLabels | nindent 10 }}
          {{- end }}
  {{- else }}
  preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      podAffinityTerm:
        topologyKey: "kubernetes.io/hostname"
        labelSelector:
          matchLabels:
            app.kubernetes.io/name: {{ include "pwa-cache.name" . }}
            app.kubernetes.io/instance: {{ .Release.Name }}
            {{- if .Values.cache.podLabels }}
            {{- toYaml .Values.cache.podLabels | nindent 12 }}
            {{- end }}
  {{- end }}
{{- end -}}
{{- end -}}

{{- define "pwa-cache-metrics.fullname" -}}
{{- printf "%s-%s" (include  "pwa-cache.fullname" . ) "metrics" -}}
{{- end -}}

{{- define "pwa-main-metrics.fullname" -}}
{{- printf "%s-%s" (include  "pwa-main.fullname" . ) "metrics" -}}
{{- end -}}

{{- define "pwa-cache-clear.fullname" -}}
{{- printf "%s-%s" (include  "pwa-cache.fullname" . ) "clear" -}}
{{- end -}}

{{- define "pwa-cache-clear.name" -}}
{{- printf "%s-%s" (include  "pwa-cache.name" . ) "clear" -}}
{{- end -}}

{{/*
Print jobname of pwa prefetch cron job. Jobname is only allowed to contain 51 chars.
Usage:
{{ include "pwa-prefetch.jobname" (dict "host" .host "path" .path "context" $) }}
*/}}
{{- define "pwa-prefetch.jobname" -}}
{{- printf "prefetch-%.43s" (sha1sum (cat .host (default "/" .path))) -}}
{{- end -}}

{{/*
Print url of initial page to start crawling
Usage:
{{ include "pwa-prefetch.url" (dict "protocol" .protocol "host" .host "path" .path) }}*/}}
{{- define "pwa-prefetch.url" -}}
{{- printf "%s://%s%s" (default "https" .protocol) .host (default "/" .path) -}}
{{- end -}}
