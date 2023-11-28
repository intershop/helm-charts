{{/* vim: set filetype=mustache: */}}
{{/*
Creates the probes
*/}}
{{- define "icm-as.probes" -}}
startupProbe:
  httpGet:
    path: /status/LivenessProbe
    port: mgnt
  # wait 60s then poll every 10s up to a total timeout of 120s
  failureThreshold: {{ .Values.probes.startup.failureThreshold | default 6 }}
  initialDelaySeconds: {{ .Values.probes.startup.initialDelaySeconds | default 60 }}
  periodSeconds: {{ .Values.probes.startup.periodSeconds | default 10 }}
livenessProbe:
  exec:
    command:
      - /bin/bash
      - -c
      - |
        [ -f "/tmp/liveness-status" ] || curl -f http://localhost:7744/status/LivenessProbe >/dev/null 2>&1
  #after startup: poll every 10s up to a total timeout of 30s
  failureThreshold: {{ .Values.probes.liveness.failureThreshold | default 3 }}
  initialDelaySeconds: {{ .Values.probes.liveness.initialDelaySeconds | default 0 }}
  periodSeconds: {{ .Values.probes.liveness.periodSeconds | default 10 }}
readinessProbe:
  httpGet:
    path: /status/ReadinessProbe
    port: mgnt
  #wait 60s (startup min) then poll every 5s up to a total timeout of 15s
  failureThreshold: {{ .Values.probes.readiness.failureThreshold | default 3 }}
  initialDelaySeconds: {{ .Values.probes.readiness.initialDelaySeconds | default 60 }}
  periodSeconds: {{ .Values.probes.readiness.periodSeconds | default 5 }}
{{- end -}}