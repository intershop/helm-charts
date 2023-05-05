{{/* vim: set filetype=mustache: */}}
{{/*
Creates the volume mounts
*/}}
{{- define "icm-as.volumeMounts" -}}
volumeMounts:
{{- if .Values.provideCustomConfig }}
{{- range $k, $v := .Values.provideCustomConfig }}
- mountPath: {{ $v.mountPath }}{{ $v.fileName }}
  name: {{ $k }}-volume
  subPath: {{ $v.fileName }}
{{- end }}
{{- end }}
- mountPath: /intershop/license/license.xml
  name: license-volume
  readOnly: true
  {{- if or (eq .Values.license.type "configMap") (eq .Values.license.type "secret") }}
  subPath: license.xml
  {{- else if eq .Values.license.type "csi" }}
  subPath: license
  {{- end }}
- mountPath: /intershop/sites
  name: sites-volume
{{- if .Values.persistence.customdata.enabled }}
- mountPath: {{ .Values.persistence.customdata.mountPoint }}
  name: custom-data-volume
{{- end }}
- mountPath: /intershop/customizations
  name: customizations-volume
- mountPath: /intershop/jgroups-share
  name: jgroups-volume
{{- if hasKey .Values.environment "STAGING_SYSTEM_TYPE" }}
{{- if eq .Values.environment.STAGING_SYSTEM_TYPE "editing" }}
- mountPath: /intershop/replication-conf/replication-clusters.xml
  name: replication-volume
  readOnly: true
  subPath: replication-clusters.xml
{{- end }}
{{- end }}
{{- end -}}