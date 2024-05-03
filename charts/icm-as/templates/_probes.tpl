{{/* vim: set filetype=mustache: */}}
{{/*
Creates the probes
*/}}
{{- define "icm-as.probes" -}}
livenessProbe:
  exec:
    command:
      - /bin/bash
      - -c
      - |
        # Using a status file to circumvent liveness probe during heap dump creation
        # See https://github.com/intershop/helm-charts/issues/491 and
        # https://github.com/kubernetes/kubernetes/issues/57187.
        [ -f "/tmp/liveness-status" ] || curl -f http://localhost:7744/status/LivenessProbe >/dev/null 2>&1
  #after startup: poll every 10s up to a total timeout of 30s
  failureThreshold: {{ .Values.probes.liveness.failureThreshold | default 6 }}
  initialDelaySeconds: {{ .Values.probes.liveness.initialDelaySeconds | default 120 }}
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