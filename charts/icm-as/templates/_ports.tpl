{{/* vim: set filetype=mustache: */}}
{{/*
Creates the ports
*/}}
{{- define "icm-as.ports" -}}
ports:
# Servlet engine service connector port
- name: svc
  containerPort: {{ .Values.ports.svc }}
  protocol: TCP
# Servlet engine management connector port
- name: mgnt
  containerPort: {{ .Values.ports.mgnt }}
  protocol: TCP
{{- if .Values.jvm.debug.enabled }}
# Java Debug port
- name: debug
  containerPort: {{ .Values.ports.debug }}
  protocol: TCP
{{- end }}
# JMX port
- name: jmx
  containerPort: {{ .Values.ports.jmx }}
  protocol: TCP
{{- end -}}