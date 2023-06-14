{{/* vim: set filetype=mustache: */}}
{{/*
Creates init-containers
*/}}
{{- define "icm-as.initContainers" -}}
initContainers:
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