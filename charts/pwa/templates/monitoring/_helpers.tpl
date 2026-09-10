{{- define "pwa-prometheus.fullname" -}}
{{- printf "%s-%s" (include  "pwa.fullname" . ) "prometheus" -}}
{{- end -}}

{{- define "pwa-prometheus.name" -}}
{{- printf "%s-%s" (include  "pwa.name" . ) "prometheus" -}}
{{- end -}}

{{- define "pwa-prometheus.config" -}}
{{- printf "%s-%s" (include  "pwa-prometheus.fullname" . ) "config" -}}
{{- end -}}

{{- define "pwa-prometheus.data" -}}
{{- printf "%s-%s" (include  "pwa-prometheus.fullname" . ) "data" -}}
{{- end -}}

{{- define "pwa-grafana.fullname" -}}
{{- printf "%s-%s" (include  "pwa.fullname" . ) "grafana" -}}
{{- end -}}

{{- define "pwa-grafana.name" -}}
{{- printf "%s-%s" (include  "pwa.name" . ) "grafana" -}}
{{- end -}}

{{- define "pwa-grafana.config" -}}
{{- printf "%s-%s" (include  "pwa-grafana.fullname" . ) "config" -}}
{{- end -}}

{{- define "pwa-grafana.data" -}}
{{- printf "%s-%s" (include  "pwa-grafana.fullname" . ) "data" -}}
{{- end -}}
