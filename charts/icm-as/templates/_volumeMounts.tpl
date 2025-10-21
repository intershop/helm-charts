{{/* vim: set filetype=mustache: */}}
{{/*
Creates the volume mounts
*/}}
{{- define "icm-as.volumeMounts" -}}
volumeMounts:
- mountPath: /intershop/sites
  name: sites-volume
- mountPath: /intershop/system-conf/cluster/encryption
  name: encryption-volume
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
{{- $replicationUsesReplicationClustersXmlConfiguration := include "icm-as.replicationUsesReplicationClustersXmlConfiguration" . | eq "true" }}
{{- if $replicationUsesReplicationClustersXmlConfiguration }}
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
{{- if .Values.secretMounts }}
{{- range $index, $mount := .Values.secretMounts }}
{{- $type := default "secret" $mount.type }}
{{- $mountPath := "" }}
{{- if $mount.targetFile }}
{{- if eq $type "secret" }}
  {{- $mountPath = printf "/secrets/%s" $mount.targetFile }}
{{- else if eq $type "certificate" }}
  {{- $mountPath = printf "/certificates/%s" $mount.targetFile }}
{{- else }}
  {{- fail (printf "Error: invalid value '%s' at secretMounts[%d].type, must be one of (secret,certificate), default=secret." $type $index) -}}
{{- end }}
- name: secretmount-{{ $index }}
  mountPath: {{ $mountPath | quote }}
  subPath: {{ $mount.targetFile | quote }}
  readOnly: true
{{- end }} {{/*if $mount.targetFile*/}}
{{- end }} {{/*range*/}}
{{- end }} {{/*if .Values.secretMounts*/}}
{{- end -}} {{/*define "icm-as.volumeMounts"*/}}
