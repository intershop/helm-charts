{{- define "ish.labels" -}}
  {{- if .Values.customerId -}}
customer-id: {{ .Values.customerId }}
  {{- end -}}
application-type: iom
{{- end }}