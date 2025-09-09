{{/* vim: set filetype=mustache: */}}
{{/*
Creates the container for the WAA
*/}}
{{- define "icm-waa.container" -}}
{{- if .Values.agent.image.tag }}
image: "{{ .Values.agent.image.repository }}:{{ .Values.agent.image.tag }}"
{{- else }}
image: "{{ .Values.agent.image.repository }}"
{{- end }}
imagePullPolicy: {{ .Values.agent.image.pullPolicy }}
env:
- name: OTEL_SERVICE_NAME
  value: {{ include "icm-web.fullname" . }}-waa
- name: ICM_ICMSERVLETURLS
  value: "cs.url.0=http://{{ .Release.Name }}-{{ .Values.appServerConnection.serviceName }}:{{ .Values.appServerConnection.port }}/servlet/ConfigurationServlet"
- name: ICM_AS_SERVICE
  value: "http://{{ .Release.Name }}-{{ .Values.appServerConnection.serviceName }}:{{ .Values.appServerConnection.port }}/servlet/ConfigurationServlet"
{{- if .Values.agent.newrelic.enabled }}
- name: ENABLE_NEWRELIC
{{- if .Values.agent.newrelic.apm.enabled }}
  value: "true"
{{- else }}
  value: "false"
{{- end }}
- name: NEW_RELIC_LICENSE_KEY
{{- /* licenseKeySecretKeyRef has precedence over license_key */ -}}
{{- if .Values.agent.newrelic.licenseKeySecretKeyRef }}
  valueFrom:
    secretKeyRef:
{{- toYaml .Values.agent.newrelic.licenseKeySecretKeyRef | nindent 6 }}
{{- else }}
  value: "{{ .Values.agent.newrelic.license_key }}"
{{- end }}
{{- end }}
{{- if .Values.environment }}
  {{- range $key, $value := .Values.environment }}
- name: {{ $key }}
  value: {{ $value | quote }}
  {{- end }}
{{- end }}
volumeMounts:
- name: pagecache-volume
  mountPath: /intershop/pagecache
{{- if .Values.agent.newrelic.enabled }}
- mountPath: /intershop/newrelic/newrelic.yml
  name: waa-newrelic-config-volume
  readOnly: true
  subPath: newrelic.yml
{{- end }}
{{- if .Values.persistence.customdata.enabled }}
- name: custom-data-volume
  mountPath: {{ .Values.persistence.customdata.mountPoint }}
{{- end }}
resources:
  {{- toYaml .Values.resources.agent | nindent 12 }}
{{- end -}}