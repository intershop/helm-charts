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
- mountPath: /intershop/sites
  name: sites-volume
{{- if .Values.persistence.customdata.enabled }}
- mountPath: {{ .Values.persistence.customdata.mountPoint }}
  name: custom-data-volume
{{- end }}
- mountPath: /intershop/customizations
  name: customizations-volume
{{- if eq (include "icm-as.jgroups.discovery" .) "file_ping" }}
- mountPath: /intershop/jgroups-share
  name: jgroups-volume
{{- end }}
{{- if and (.Values.replication.enabled) (eq .Values.replication.role "source")}}
- mountPath: /intershop/replication-conf/replication-clusters.xml
  name: replication-volume
  readOnly: true
  subPath: replication-clusters.xml
{{- end }}
- mountPath: /intershop/jgroups-conf/jgroups-config.xml
  name: jgroups-config-volume
  readOnly: true
  subPath: jgroups-config.xml
{{- if .Values.webLayer.redis.enabled }}
- mountPath: /intershop/redis-conf/redis-client-config.yaml
  name: redis-client-config-volume
  readOnly: true
  subPath: redis-client-config.yaml
{{- end }}
{{- if .Values.newrelic.enabled }}
- mountPath: /intershop/lib-newrelic/newrelic.yml
  name: newrelic-config-volume
  readOnly: true
  subPath: newrelic.yml
{{- end }}
{{- if .Values.sslCertificateRetrieval.enabled }}
- mountPath: /mnt/secrets
  name: secrets-store-inline
{{- end }}
{{- end -}}