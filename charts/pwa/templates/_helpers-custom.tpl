{{/*
Project-specific helpers for the PWA chart.

These are intentionally kept separate from the `helm create` scaffold baseline in
_helpers.tpl so scaffold updates stay easy to diff and re-apply. Add chart-specific
helpers here rather than in _helpers.tpl.
*/}}

{{/*
Component fullname: "<release-fullname>-<component>".
Usage: {{ include "pwa.componentName" (dict "root" . "component" "app") }}
*/}}
{{- define "pwa.componentName" -}}
{{- printf "%s-%s" (include "pwa.fullname" .root) .component | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Full label set for a component (common labels + component + version).
The version label tracks the component's deployed image tag so it stays truthful
when app.image.tag / proxy.image.tag is overridden (not just the chart appVersion).
Usage: {{ include "pwa.componentLabels" (dict "root" . "component" "app") }}
*/}}
{{- define "pwa.componentLabels" -}}
{{ include "pwa.commonLabels" .root }}
app.kubernetes.io/component: {{ .component }}
{{- with (include "pwa.componentVersion" (dict "root" .root "component" .component)) }}
app.kubernetes.io/version: {{ . | quote }}
{{- end }}
{{- end }}

{{/*
Version label value for a tier (app/proxy): the deployed image tag, else the default
release-<appVersion>. Guarded to a valid label value (<=63 chars, no trailing -._).
Components without an image config (e.g. the dev-only monitoring stack) get no version label.
*/}}
{{- define "pwa.componentVersion" -}}
{{- $cfg := index .root.Values .component -}}
{{- if kindIs "map" $cfg -}}
{{- $tag := "" -}}
{{- if kindIs "map" $cfg.image -}}
{{- $tag = $cfg.image.tag -}}
{{- end -}}
{{- $tag | default (printf "release-%s" .root.Chart.AppVersion) | trunc 63 | trimSuffix "-" | trimSuffix "." | trimSuffix "_" -}}
{{- end -}}
{{- end -}}

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
Pod anti-affinity for a component (spreads Pods across nodes).
Usage: {{ include "pwa.podAntiAffinity" (dict "root" . "component" "app") }}
*/}}
{{- define "pwa.podAntiAffinity" -}}
{{- $cfg := index .root.Values .component -}}
{{- if $cfg.podAntiAffinity.enabled -}}
podAntiAffinity:
  {{- if $cfg.podAntiAffinity.required }}
  requiredDuringSchedulingIgnoredDuringExecution:
    - topologyKey: "kubernetes.io/hostname"
      labelSelector:
        matchLabels:
          {{- include "pwa.selectorLabels" (dict "root" .root "component" .component) | nindent 10 }}
  {{- else }}
  preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      podAffinityTerm:
        topologyKey: "kubernetes.io/hostname"
        labelSelector:
          matchLabels:
            {{- include "pwa.selectorLabels" (dict "root" .root "component" .component) | nindent 12 }}
  {{- end }}
{{- end -}}
{{- end -}}
