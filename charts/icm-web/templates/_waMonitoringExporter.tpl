{{/* vim: set filetype=mustache: */}}
{{- define "icm-wa.monitoringContainer" -}}
{{- $waMon := default dict .Values.waMonitoring }}
{{- if dig "enabled" true $waMon }}
- name: "{{ .Chart.Name }}-wa-monitoring"
  {{- if not (dig "image" "repository" "" $waMon) }}
    {{- fail "Error: missing value at waMonitoring.image.repository." -}}
  {{- end }}
  image: {{ $waMon.image.repository | quote }}
  imagePullPolicy: {{ (dig "image" "pullPolicy" "IfNotPresent" $waMon) | quote }}
  env:
  - name: WA_CONFIG
    value: "env"
  - name: WA_TENANT
    value: {{ include "icm-web.customerId" . }}
  - name: WA_ENVIRONMENT
    value: {{ printf "%s-%s" (include "icm-web.environmentType" .) (include "icm-web.stagingType" .) }}
  - name: WA_SKIP_CERT_VALIDATION
    value: "true"
  - name: WA_APP_SERVER_UNAVAILABLE_TIMEOUT
    value: {{ (dig "appServerUnavailableTimeout" "30s" $waMon) | quote }}
  - name: WA_LOG
    value: "/intershop/logs"
  - name: WA_URI
    value: "http://localhost:8080/INTERSHOP/wastatistics"
  - name: HTTPD_STATUS_URI
    value: "http://localhost:8080/server-status?auto"
  - name: SCRAPE_INTERVAL
    value: {{ (dig "scrapingInterval" "5s" $waMon) | quote }}
  ports:
  - name: metrics
    containerPort: 2112
    protocol: TCP
  resources:
    limits:
      cpu: 100m
      memory: 100Mi
    requests:
      cpu: 100m
      memory: 100Mi
  volumeMounts:
    - name: "logs-volume"
      mountPath: "/intershop/logs"
{{- end }}
{{- end -}}
