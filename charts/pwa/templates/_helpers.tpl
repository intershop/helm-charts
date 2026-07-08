{{/*
Expand the name of the chart.
*/}}
{{- define "pwa.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "pwa.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Chart name and version as used by the chart label.
*/}}
{{- define "pwa.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels (chart-wide). Not component specific.
*/}}
{{- define "pwa.labels" -}}
helm.sh/chart: {{ include "pwa.chart" . }}
app.kubernetes.io/name: {{ include "pwa.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/part-of: {{ include "pwa.name" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Name of the ServiceAccount to use.
*/}}
{{- define "pwa.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "pwa.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Component fullname: "<release-fullname>-<component>".
Usage: {{ include "pwa.componentName" (dict "root" . "component" "app") }}
*/}}
{{- define "pwa.componentName" -}}
{{- printf "%s-%s" (include "pwa.fullname" .root) .component | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Selector labels for a component (stable, immutable set).
Usage: {{ include "pwa.selectorLabels" (dict "root" . "component" "app") }}
*/}}
{{- define "pwa.selectorLabels" -}}
app.kubernetes.io/name: {{ include "pwa.name" .root }}
app.kubernetes.io/instance: {{ .root.Release.Name }}
app.kubernetes.io/component: {{ .component }}
{{- end }}

{{/*
Full label set for a component (common labels + component label).
Usage: {{ include "pwa.componentLabels" (dict "root" . "component" "app") }}
*/}}
{{- define "pwa.componentLabels" -}}
{{ include "pwa.labels" .root }}
app.kubernetes.io/component: {{ .component }}
{{- end }}

{{/*
Fully qualified in-cluster hostname the proxy uses to reach the app service.
*/}}
{{- define "pwa.appUpstream" -}}
{{- printf "http://%s:%v" (include "pwa.componentName" (dict "root" . "component" "app")) .Values.app.service.port }}
{{- end }}

{{/*
Whether Prometheus metrics should be exposed by the app.
*/}}
{{- define "pwa.appMetricsEnabled" -}}
{{- if or .Values.app.metrics.enabled .Values.monitoring.enabled }}true{{ end -}}
{{- end }}

{{/*
Whether Prometheus metrics should be exposed by the proxy.
*/}}
{{- define "pwa.proxyMetricsEnabled" -}}
{{- if or .Values.proxy.metrics.enabled .Values.monitoring.enabled }}true{{ end -}}
{{- end }}

{{- define "pwa.appMetricsFullname" -}}
{{- printf "%s-%s" (include "pwa.componentName" (dict "root" . "component" "app")) "metrics" -}}
{{- end -}}

{{- define "pwa.proxyMetricsFullname" -}}
{{- printf "%s-%s" (include "pwa.componentName" (dict "root" . "component" "proxy")) "metrics" -}}
{{- end -}}

{{/*
app pod anti affinity
*/}}
{{- define "app.podAntiAffinity" -}}
{{- if .Values.app.podAntiAffinity.enabled -}}
podAntiAffinity:
  {{- if .Values.app.podAntiAffinity.required }}
  requiredDuringSchedulingIgnoredDuringExecution:
    - topologyKey: "kubernetes.io/hostname"
      labelSelector:
        matchLabels:
          app.kubernetes.io/name: {{ include "pwa.componentName" (dict "root" . "component" "app") }}
          app.kubernetes.io/instance: {{ .Release.Name }}
          {{- if .Values.app.podLabels }}
          {{- toYaml .Values.app.podLabels | nindent 10 }}
          {{- end }}
  {{- else }}
  preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      podAffinityTerm:
        topologyKey: "kubernetes.io/hostname"
        labelSelector:
          matchLabels:
            app.kubernetes.io/name: {{ include "pwa.componentName" (dict "root" . "component" "app") }}
            app.kubernetes.io/instance: {{ .Release.Name }}
            {{- if .Values.app.podLabels }}
            {{- toYaml .Values.app.podLabels | nindent 12 }}
            {{- end }}
  {{- end }}
{{- end -}}
{{- end -}}

{{/*
proxy pod anti affinity
*/}}
{{- define "proxy.podAntiAffinity" -}}
{{- if .Values.proxy.podAntiAffinity.enabled -}}
podAntiAffinity:
  {{- if .Values.proxy.podAntiAffinity.required }}
  requiredDuringSchedulingIgnoredDuringExecution:
    - topologyKey: "kubernetes.io/hostname"
      labelSelector:
        matchLabels:
          app.kubernetes.io/name: {{ include "pwa.componentName" (dict "root" . "component" "proxy") }}
          app.kubernetes.io/instance: {{ .Release.Name }}
          {{- if .Values.proxy.podLabels }}
          {{- toYaml .Values.proxy.podLabels | nindent 10 }}
          {{- end }}
  {{- else }}
  preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      podAffinityTerm:
        topologyKey: "kubernetes.io/hostname"
        labelSelector:
          matchLabels:
            app.kubernetes.io/name: {{ include "pwa.componentName" (dict "root" . "component" "proxy") }}
            app.kubernetes.io/instance: {{ .Release.Name }}
            {{- if .Values.proxy.podLabels }}
            {{- toYaml .Values.proxy.podLabels | nindent 12 }}
            {{- end }}
  {{- end }}
{{- end -}}
{{- end -}}

