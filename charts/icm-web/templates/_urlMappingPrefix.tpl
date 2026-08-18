{{/* vim: set filetype=mustache: */}}

{{/*
Renders the urlMappingPrefix
*/}}

{{- define "icm-web.urlMappingPrefix" -}}
  {{- .Values.urlMappingPrefix | default "/INTERSHOP" -}}
{{- end -}}

{{- define "icm-web.urlMappingPrefixFull" -}}
  {{- printf "%s/wastatus" (include "icm-web.urlMappingPrefix" . ) | quote -}}
{{- end -}}

