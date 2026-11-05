{{- define "pwa-prometheus.fullname" -}}
{{- include "pwa.suffixedName" (dict "root" . "suffix" "prometheus") -}}
{{- end -}}

{{- define "pwa-prometheus.config" -}}
{{- include "pwa.suffixedName" (dict "root" . "suffix" "prometheus-config") -}}
{{- end -}}

{{- define "pwa-prometheus.data" -}}
{{- include "pwa.suffixedName" (dict "root" . "suffix" "prometheus-data") -}}
{{- end -}}

{{- define "pwa-grafana.fullname" -}}
{{- include "pwa.suffixedName" (dict "root" . "suffix" "grafana") -}}
{{- end -}}

{{- define "pwa-grafana.config" -}}
{{- include "pwa.suffixedName" (dict "root" . "suffix" "grafana-config") -}}
{{- end -}}

{{- define "pwa-grafana.data" -}}
{{- include "pwa.suffixedName" (dict "root" . "suffix" "grafana-data") -}}
{{- end -}}
