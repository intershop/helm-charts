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
          app.kubernetes.io/name: {{ include "pwa.componentName" (dict "root" .root "component" .component) }}
          app.kubernetes.io/instance: {{ .root.Release.Name }}
          {{- if $cfg.podLabels }}
          {{- toYaml $cfg.podLabels | nindent 10 }}
          {{- end }}
  {{- else }}
  preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      podAffinityTerm:
        topologyKey: "kubernetes.io/hostname"
        labelSelector:
          matchLabels:
            app.kubernetes.io/name: {{ include "pwa.componentName" (dict "root" .root "component" .component) }}
            app.kubernetes.io/instance: {{ .root.Release.Name }}
            {{- if $cfg.podLabels }}
            {{- toYaml $cfg.podLabels | nindent 12 }}
            {{- end }}
  {{- end }}
{{- end -}}
{{- end -}}
