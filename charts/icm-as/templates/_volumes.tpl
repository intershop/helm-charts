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
- name: license-volume
{{- if eq .Values.license.type "configMap" }}
  configMap:
    defaultMode: 420
    name: {{ template "icm-as.fullname" . }}-license
{{- else if eq .Values.license.type "csi" }}
  csi:
    driver: secrets-store.csi.k8s.io
    readOnly: true
  {{ toYaml .Values.license.csi | nindent 4 }}
{{- else if eq .Values.license.type "secret" }}
  secret:
    secretName: {{ .Values.license.secret.name }}
{{- end }}
{{- include "icm-as.volume" (list . "jgroups" .Values.persistence.jgroups) }}
{{- include "icm-as.volume" (list . "sites" .Values.persistence.sites) }}
{{- if and (.Values.replication.enabled) (eq .Values.replication.role "source")}}
- name: replication-volume
  configMap:
    name: {{ template "icm-as.fullname" . }}-replication-clusters-xml
{{- end }}
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
- name: {{ $volumeName }}-volume
{{- if eq $volumeValues.type "azurefiles" }}
  azureFile:
    secretName: {{ $volumeValues.azurefiles.secretName }}
    shareName: {{ $volumeValues.azurefiles.shareName }}
    readOnly: false
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