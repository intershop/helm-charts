{{/* vim: set filetype=mustache: */}}
{{/*
Creates the volumes used by an ICM
*/}}
{{- define "icm-as.volumes" -}}
volumes:
{{- if .Values.provideCustomConfig }}
{{- range $k, $v := .Values.provideCustomConfig }}
- name: {{ $k }}-volume
  configMap:
    name: {{ template "icm-as.fullname" $ }}-system-conf-cluster
    defaultMode: 420
{{- end }}
{{- end }}
{{- if .Values.newrelic.enabled }}
- name: newrelic-config-volume
  configMap:
    defaultMode: 420
    name: {{ template "icm-as.fullname" . }}-newrelic-yml
{{- end }}
{{- if eq (include "icm-as.jgroups.discovery" .) "file_ping" }}
{{- include "icm-as.volume" (list . "jgroups" .Values.persistence.jgroups .Values.podSecurityContext) }}
{{- end }}
{{- include "icm-as.volume" (list . "sites" .Values.persistence.sites .Values.podSecurityContext) }}
{{- if and (.Values.replication.enabled) (eq .Values.replication.role "source")}}
- name: replication-volume
  configMap:
    name: {{ template "icm-as.fullname" . }}-replication-clusters-xml
{{- end }}
{{- if .Values.webLayer.redis.enabled }}
- name: redis-client-config-volume
  configMap:
    name: {{ template "icm-as.fullname" . }}-redis-client-config-yaml
{{- end }}
- name: jgroups-config-volume
  configMap:
    name: {{ template "icm-as.fullname" . }}-jgroups-config-xml
{{- if .Values.persistence.customdata.enabled }}
- name: custom-data-volume
  persistentVolumeClaim:
    claimName: "{{ .Values.persistence.customdata.existingClaim }}"
{{- end }}
- name: customizations-volume
  emptyDir: {}
{{- if .Values.sslCertificateRetrieval.enabled }}
- name: secrets-store-inline
  csi:
    driver: secrets-store.csi.k8s.io
    readOnly: true
    volumeAttributes:
      secretProviderClass: {{ include "icm-as.fullname" . }}-cert
{{- end }}
{{- end -}}

{{/*
Creates a volume named {$name}-volume
*/}}
{{- define "icm-as.volume" -}}
{{- $values := index . 0 }}
{{- $volumeName := index . 1 }}
{{- $volumeValues := index . 2 }}
{{- $podSecurityValues := index . 3 }}
- name: {{ $volumeName }}-volume
{{- if eq $volumeValues.type "azurefiles" }}
  csi:
    driver: file.csi.azure.com
    readOnly: false
    volumeAttributes:
      secretName: {{ $volumeValues.azurefiles.secretName }}
      shareName: {{ $volumeValues.azurefiles.shareName }}
      mountOptions: "uid={{ $podSecurityValues.runAsUser }},gid={{ $podSecurityValues.runAsGroup }}"
{{- else if eq $volumeValues.type "emptyDir" }}
  emptyDir: {}
{{- else if eq $volumeValues.type "existingClaim" }}
  persistentVolumeClaim:
    claimName: "{{ $volumeValues.existingClaim }}"
{{- else }}
  persistentVolumeClaim:
    claimName: "{{ template "icm-as.fullname" $values }}-{{$volumeValues.type}}-{{$volumeName}}-pvc"
{{- end }}
{{- end -}}