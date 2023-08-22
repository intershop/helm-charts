{{- define "ish.labels" -}}
  {{- if and .Values.customerId (not (hasPrefix "$" .Values.customerId)) -}}
customer-id: {{ .Values.customerId }}
  {{- end }}
application-type: iom
{{- end }}
