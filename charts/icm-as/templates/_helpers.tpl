{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "icm-as.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "icm-as.fullname" -}}
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
{{- define "icm-as.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "icm-as.labels" -}}
helm.sh/chart: {{ include "icm-as.chart" . }}
{{ include "icm-as.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "icm-as.selectorLabels" -}}
app.kubernetes.io/name: {{ include "icm-as.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "icm-as.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "icm-as.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the values for the environment variable FEATURED_JVM_ARGUMENTS.
These are predefined parameter from serveral features.
*/}}
{{- define "icm-as.featuredJVMArguments" -}}
{{- $addVmOptions := list -}}
{{- $addVmOptions = append $addVmOptions .Values.jvm.options -}}
{{- if .Values.datadog.enabled -}}
    {{- $addVmOptions = append $addVmOptions .Values.datadog.options -}}
{{- end -}}
- name: FEATURED_JVM_ARGUMENTS
  value: {{ join " " $addVmOptions | quote }}
{{- end -}}

{{/*
Create the values for the environment variable ADDITIONAL_JVM_ARGUMENTS.
These are additional parameters defined by deployment, which are not indented to override feature specific parameter.
*/}}
{{- define "icm-as.additionalJVMArguments" -}}
{{- $addVmOptions := list -}}
{{- $addVmOptions = append $addVmOptions .Values.jvm.additionalOptions -}}
{{- if .Values.datadog.enabled -}}
    {{- $addVmOptions = append $addVmOptions .Values.datadog.additionalOptions -}}
{{- end -}}
- name: ADDITIONAL_JVM_ARGUMENTS
  value: {{ join " " $addVmOptions | quote }}
{{- end -}}

{{/*
Creates a chart-label
*/}}
{{- define "icm-as.chartLabel" -}}
chart: "{{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}"
{{- end -}}

{{/*
Applies datadog labels
*/}}
{{- define "icm-as.datadogLabels" -}}
{{- if .Values.datadog.enabled -}}
tags.datadoghq.com/env: {{ .Values.datadog.env }}
tags.datadoghq.com/service: {{ include "icm-as.fullname" . }}
{{- if .Values.image.tag -}}
tags.datadoghq.com/version: {{ .Values.image.tag }}
{{- else }}
tags.datadoghq.com/version: {{ (split ":" .Values.image.repository)._1 }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
Creates resources
*/}}
{{- define "icm-as.resources" -}}
resources: {{- toYaml .Values.resources | nindent 2 }}
{{- end -}}

{{/*
Pod-annotations
*/}}
{{- define "icm-as.podData" -}}
{{- if .Values.podAnnotations -}}
annotations: {{- toYaml .Values.podAnnotations | nindent 2 }}
{{- end }}
{{- end -}}

{{/*
Pod-labels
*/}}
{{- define "icm-as.podLabels" -}}
{{- with .Values.podLabels }}
{{- . | toYaml | nindent 0 }}
{{- end }}
{{- end -}}

{{/*
AAD Pod-binding label
*/}}
{{- define "icm-as.podBinding" -}}
{{- if .Values.podBinding.enabled }}
aadpodidbinding: {{ .Values.podBinding.binding }}
{{- end }}
{{- end -}}

{{/*
Node-selector
*/}}
{{- define "icm-as.nodeSelector" -}}
{{- if .Values.nodeSelector -}}
nodeSelector:
  {{- toYaml .Values.nodeSelector | nindent 2 }}
{{- end }}
{{- end -}}

{{/*
Image spec
*/}}
{{- define "icm-as.image" -}}
image: "{{ .Values.image.repository }}{{ if not (contains ":" .Values.image.repository) }}:{{ .Values.image.tag | default .Chart.AppVersion }}{{ end }}"
imagePullPolicy: "{{ .Values.image.pullPolicy }}"
{{- if .Values.customCommand }}
command: {{- toYaml .Values.customCommand | nindent 2 }}
{{- end }}
{{- end -}}

{{/*
imagePullSecrets spec
*/}}
{{- define "icm-as.imagePullSecrets" -}}
{{- if .Values.imagePullSecrets -}}
imagePullSecrets:
{{- range .Values.imagePullSecrets }}
- name: {{ . | quote }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Applies security context information
*/}}
{{- define "icm-as.podSecurityContext" -}}
{{- if .Values.podSecurityContext -}}
securityContext:
  {{- toYaml .Values.podSecurityContext | nindent 2 }}
{{- end }}
{{- end -}}
