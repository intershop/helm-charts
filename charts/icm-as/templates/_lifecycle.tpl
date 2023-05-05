{{/* vim: set filetype=mustache: */}}
{{/*
Creates the lifecycle
*/}}
{{- define "icm-as.lifecycle" -}}
lifecycle:
  preStop:
    httpGet:
      port: mgnt
      path: /status/action/shutdown
terminationMessagePath: /dev/termination-log
terminationMessagePolicy: File
{{- end -}}