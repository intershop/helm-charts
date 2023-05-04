{{/* vim: set filetype=mustache: */}}
{{/*
Creates the ports
*/}}
{{- define "icm-as.ports" }}
ports:
# Servlet engine service connector port
- name: svc
  containerPort: 7743
  protocol: TCP
# Servlet engine management connector port
- name: mgnt
  containerPort: 7744
  protocol: TCP
{{- if .Values.jvm.debug.enabled }}
# Java Debug port
- name: debug
  containerPort: 7746
  protocol: TCP
{{- end }}
# JMX port
- name: jmx
  containerPort: 7747
  protocol: TCP
{{- end -}}