{{/* vim: set filetype=mustache: */}}

{{/*
Renders the urlMappingPrefix
*/}}

{{- define "icm-web.urlMappingPrefix" -}}
  {{- $prefix := .Values.urlMappingPrefix | default "/INTERSHOP" -}}
  {{- ternary $prefix (printf "/%s" $prefix) (hasPrefix "/" $prefix) -}}
{{- end -}}

{{- define "icm-web.urlMappingPrefixFull" -}}
  {{- printf "%s/wastatus" (include "icm-web.urlMappingPrefix" . ) | quote -}}
{{- end -}}
