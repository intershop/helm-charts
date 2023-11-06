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
environment-name: {{ include "icm-as.environmentName" . }}
operational-context: {{ include "icm-as.operationalContextName" . }}
{{ include "icm-as.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
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
  {{ default (printf "%s-%s" (include "icm-as.fullname" .) "default") .Values.serviceAccount.name }}
{{- end -}}

{{/*
Create the values for the environment variable FEATURED_JVM_ARGUMENTS.
These are predefined parameter from serveral features.
*/}}
{{- define "icm-as.featuredJVMArguments" -}}
{{- $addVmOptions := list -}}
{{- $addVmOptions = append $addVmOptions .Values.jvm.options -}}
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
Creates resources
*/}}
{{- define "icm-as.resources" -}}
resources: {{- toYaml .Values.resources | nindent 2 }}
{{- end -}}

{{/*
Pod-annotations
*/}}
{{- define "icm-as.podData" -}}
annotations:
  {{- if .Values.newrelic.metrics.enabled }}
  prometheus.io/scrape: 'true'
  {{- else }}
  prometheus.io/scrape: 'false'
  {{- end }}
  prometheus.io/port: '7744'
  prometheus.io/path: '/metrics'
{{- if .Values.podAnnotations -}}
{{- toYaml .Values.podAnnotations | nindent 2 }}
{{- end }}
{{- end -}}

{{/*
Pod-labels
*/}}
{{- define "icm-as.podLabels" -}}
jgroupscluster: "{{- .Values.jgroups.clusterLabel | default .Release.Name -}}"
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

{{/*
The discovery mode of jgroups messaging
*/}}
{{- define "icm-as.jgroups.discovery" -}}
{{- if .Values.jgroups -}}
  {{- if .Values.jgroups.discovery -}}
    {{- .Values.jgroups.discovery -}}
  {{- else -}}
    {{- printf "file_ping" }}
  {{- end -}}
{{- else -}}
    {{- printf "file_ping" }}
{{- end -}}
{{- end -}}

