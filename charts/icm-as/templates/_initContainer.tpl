{{/* vim: set filetype=mustache: */}}
{{/*
Creates init-containers
*/}}
{{- define "icm-as.initContainers" -}}
initContainers:
{{- if eq .Values.persistence.sites.type "local" }}
# the following container
# 1) only is active if local storage is enabled
# 2) applies permission 777 to sites volume
# 3) makes user/group intershop owner of sites volume
# !) This is necessary for Windows users with Docker Desktop using WSL[2] backend because:
#    Docker Desktop with WSL[2] creates folders for local volume mounts assigning the user root and permissions 700
- name: sites-volume-mount-hack
  image: busybox
  command:
  - "/bin/sh"
  - "-c"
  - |
    chmod 777 /intershop/sites && chown -R 150:150 /intershop/sites
{{- if eq (include "icm-as.jgroups.discovery" .) "file_ping" }}
    chmod 777 /intershop/jgroups-share && chown -R 150:150 /intershop/jgroups-share
{{- end }}
  volumeMounts:
  - name: sites-volume
    mountPath: /intershop/sites
{{- if eq (include "icm-as.jgroups.discovery" .) "file_ping" }}
  - name: jgroups-volume
    mountPath: /intershop/jgroups-share
{{- end }}
  securityContext:
    runAsUser: 0
{{- end }}
{{- if .Values.copySitesDir.enabled }}
- name: cp-sites-dir
  image: "{{ .Values.image.repository }}{{ if not (contains ":" .Values.image.repository) }}:{{ .Values.image.tag | default .Chart.AppVersion }}{{ end }}"
  command:
  - "/bin/sh"
  - "-c"
  - |
    set -x
    SITES_DIR={{ .Values.copySitesDir.fromDir }}
    if [ -d "$SITES_DIR" ]; then
      SITES_VOL=/intershop
      cp -r $SITES_DIR $SITES_VOL
      chmod 777 $SITES_VOL/sites && chown -R {{ .Values.copySitesDir.chmodUser }}:{{ .Values.copySitesDir.chmodGroup }} $SITES_VOL/sites
      find $SITES_VOL -type f > "{{ .Values.copySitesDir.resultDir }}/sites.txt"
    fi
  imagePullPolicy: "IfNotPresent"
  securityContext:
    runAsUser: 0
    runAsGroup: 0
  volumeMounts:
  - name: sites-volume
    mountPath: /intershop/sites
  {{- if $.Values.persistence.customdata.enabled }}
  - mountPath: {{ $.Values.persistence.customdata.mountPoint }}
    name: custom-data-volume
  {{- end }}
{{- end }}
{{- if .Values.customizations }}
{{- range $k, $v := .Values.customizations }}
- name: {{ $k }}
  image: {{ $v.repository }}
  imagePullPolicy: {{ $v.pullPolicy | default "IfNotPresent" }}
  volumeMounts:
  - mountPath: /customizations
    name: customizations-volume
{{- end }}
{{- end }}
{{- end -}}