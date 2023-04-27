{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "icm-as.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "icm-as.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "icm-as.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "icm-as.labels" -}}
helm.sh/chart: {{ include "icm-as.chart" . }}
{{ include "icm-as.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "icm-as.selectorLabels" -}}
app.kubernetes.io/name: {{ include "icm-as.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "icm-as.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "icm-as.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the values for the environment variable FEATURED_JVM_ARGUMENTS.
These are predefined parameter from serveral features.
*/}}
{{- define "icm-as.featuredJVMArguments" -}}
    {{- $addVmOptions := list -}}
    {{- $addVmOptions = append $addVmOptions .Values.jvm.options -}}
    {{- if .Values.datadog.enabled -}}
        {{- $addVmOptions = append $addVmOptions .Values.datadog.options -}}
    {{- end -}}
- name: FEATURED_JVM_ARGUMENTS
  value: {{ join " " $addVmOptions | quote }}
{{- end -}}

{{/*
Create the values for the environment variable ADDITIONAL_JVM_ARGUMENTS.
These are additional parameters defined by deployment, which are not indented to override feature specific parameter.
*/}}
{{- define "icm-as.additionalJVMArguments" -}}
    {{- $addVmOptions := list -}}
    {{- $addVmOptions = append $addVmOptions .Values.jvm.additionalOptions -}}
    {{- if .Values.datadog.enabled -}}
        {{- $addVmOptions = append $addVmOptions .Values.datadog.additionalOptions -}}
    {{- end -}}
- name: ADDITIONAL_JVM_ARGUMENTS
  value: {{ join " " $addVmOptions | quote }}
{{- end -}}

{{/*
Creates a chart-label
*/}}
{{- define "icm-as.chartLabel" }}
chart: "{{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}"
{{- end -}}

{{/*
Applies datadog labels
*/}}
{{- define "icm-as.datadogLabels" }}
{{- if .Values.datadog.enabled }}
tags.datadoghq.com/env: {{ .Values.datadog.env }}
tags.datadoghq.com/service: {{ include "icm-as.fullname" . }}
{{- if .Values.image.tag }}
tags.datadoghq.com/version: {{ .Values.image.tag }}
{{- else }}
tags.datadoghq.com/version: {{ (split ":" .Values.image.repository)._1 }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
Creates resources
*/}}
{{- define "icm-as.resources" }}
resources:
  {{- toYaml .Values.resources | trim | nindent 2 }}
{{- end -}}

{{/*
Creates the lifecycle
*/}}
{{- define "icm-as.lifecycle" }}
lifecycle:
  preStop:
    httpGet:
      port: mgnt
      path: /status/action/shutdown
terminationMessagePath: /dev/termination-log
terminationMessagePolicy: File
{{- end -}}

{{/*
Pod-annotations and bindings
*/}}
{{- define "icm-as.podData" }}
{{- if .Values.podAnnotations }}
annotations:
{{- toYaml .Values.podAnnotations | trim | nindent 8 }}
{{- end }}
{{- if .Values.podBinding.enabled }}
aadpodidbinding: {{ .Values.podBinding.binding }}
{{- end }}
{{- end -}}

{{/*
Pod-label
*/}}
{{- define "icm-as.podLabels" }}
{{- if .Values.podLabels }}
  {{- toYaml .Values.podLabels | trim | nindent 2 }}
{{- end }}
{{- end -}}

{{/*
Node-selector
*/}}
{{- define "icm-as.nodeSelector" }}
{{- if .Values.nodeSelector}}
nodeSelector:
  {{- toYaml .Values.nodeSelector | trim | nindent 2 }}
{{- end }}
{{- end -}}

{{/*
Image spec
*/}}
{{- define "icm-as.image" }}
image: "{{ .Values.image.repository }}{{ if not (contains ":" .Values.image.repository) }}:{{ .Values.image.tag | default .Chart.AppVersion }}{{ end }}"
imagePullPolicy: "{{ .Values.image.pullPolicy }}"
{{- if .Values.customCommand }}
command:
  {{- toYaml .Values.customCommand | trim | nindent 10 }}
{{- end }}
{{- end -}}

{{/*
imagePullSecrets spec
*/}}
{{- define "icm-as.imagePullSecrets" }}
{{- if .Values.imagePullSecrets }}
imagePullSecrets:
  {{- range .Values.imagePullSecrets }}
  - name: {{ . | quote }}
  {{- end }}
{{- end }}
{{- end -}}

{{/*
Creates the probes
*/}}
{{- define "icm-as.probes" }}
startupProbe:
  httpGet:
    path: /status/LivenessProbe
    port: mgnt
  # wait 60s then poll every 10s up to a total timeout of 120s
  failureThreshold: {{ .Values.probes.startup.failureThreshold | default 6 }}
  initialDelaySeconds: {{ .Values.probes.startup.initialDelaySeconds | default 60 }}
  periodSeconds: {{ .Values.probes.startup.periodSeconds | default 10 }}
livenessProbe:
  httpGet:
    path: /status/LivenessProbe
    port: mgnt
  #after startup: poll every 10s up to a total timeout of 30s
  failureThreshold: {{ .Values.probes.liveness.failureThreshold | default 3 }}
  initialDelaySeconds: {{ .Values.probes.liveness.initialDelaySeconds | default 0 }}
  periodSeconds: {{ .Values.probes.liveness.periodSeconds | default 10 }}
readinessProbe:
  httpGet:
    path: /status/ReadinessProbe
    port: mgnt
  #wait 60s (startup min) then poll every 5s up to a total timeout of 15s
  failureThreshold: {{ .Values.probes.readiness.failureThreshold | default 3 }}
  initialDelaySeconds: {{ .Values.probes.readiness.initialDelaySeconds | default 60 }}
  periodSeconds: {{ .Values.probes.readiness.periodSeconds | default 5 }}
{{- end -}}

{{/*
Creates the volume mounts
*/}}
{{- define "icm-as.ports" }}
ports:
  # Servlet engine service connector port
  - name: svc
    containerPort: 7743
    protocol: TCP
  # Servlet engine management connector port
  - name: mgnt
    containerPort: 7744
    protocol: TCP
{{- if .Values.jvm.debug.enabled }}
  # Java Debug port
  - name: debug
    containerPort: 7746
    protocol: TCP
{{- end }}
  # JMX port
  - name: jmx
    containerPort: 7747
    protocol: TCP
{{- end -}}

{{/*
Creates the volume mounts
*/}}
{{- define "icm-as.volumeMounts" }}
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

{{/*
Creates the environment section
*/}}
{{- define "icm-as.env" }}
env:
{{- if not (hasKey .Values.environment "SERVER_NAME") }}
- name: SERVER_NAME
  value: "appserver"
{{- end }}
- name: IS_DBPREPARE
  value: "false"
- name: INTERSHOP_SERVER_NODE
  valueFrom:
    fieldRef:
      fieldPath: spec.nodeName
- name: INTERSHOP_SERVER_NAMESPACE
  valueFrom:
    fieldRef:
      fieldPath: metadata.namespace
- name: INTERSHOP_SERVER_PODNAME
  valueFrom:
    fieldRef:
      fieldPath: metadata.name
- name: INTERSHOP_SERVER_PODIP
  valueFrom:
    fieldRef:
      fieldPath: status.podIP
{{- if .Values.jvm.debug.enabled }}
- name: DEBUG_ICM
  value: "true"
{{- end }}
{{- if .Values.datadog.enabled }}
- name: ENABLE_DATADOG
  value: "true"
- name: DD_ENV
  valueFrom:
    fieldRef:
      fieldPath: metadata.labels['tags.datadoghq.com/env']
- name: DD_SERVICE
  valueFrom:
    fieldRef:
      fieldPath: metadata.labels['tags.datadoghq.com/service']
- name: DD_VERSION
  valueFrom:
    fieldRef:
      fieldPath: metadata.labels['tags.datadoghq.com/version']
- name: DD_LOGS_INJECTION
  value: "true"
- name: DD_AGENT_HOST
  valueFrom:
    fieldRef:
      fieldPath: status.hostIP
{{- end }}
{{- if .Values.mssql.enabled }}
- name: INTERSHOP_DATABASETYPE
  value: mssql
- name: INTERSHOP_JDBC_URL
  value: {{ printf "jdbc:sqlserver://%s-mssql-service:1433;database=%s" (include "icm-as.fullname" .) .Values.mssql.databaseName }}
- name: INTERSHOP_JDBC_USER
  value: "{{ .Values.mssql.user }}"
- name: INTERSHOP_JDBC_PASSWORD
  value: "{{ .Values.mssql.password }}"
{{- else }}
- name: INTERSHOP_DATABASETYPE
  value: "{{ .Values.database.type }}"
- name: INTERSHOP_JDBC_URL
  value: "{{ .Values.database.jdbcURL }}"
- name: INTERSHOP_JDBC_USER
  value: "{{ .Values.database.jdbcUser }}"
- name: INTERSHOP_JDBC_PASSWORD
  value: "{{ .Values.database.jdbcPassword }}"
{{- end }}
{{ include "icm-as.featuredJVMArguments" . }}
{{ include "icm-as.additionalJVMArguments" . }}
{{- range $key, $value := .Values.environment }}
- name: {{ $key }}
  value: {{ $value | quote }}
{{- end -}}
{{- end -}}

{{/*
Creates init-containers
*/}}
{{- define "icm-as.initContainers" }}
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
    command: ["sh", "-c", "chmod 777 /intershop/sites && chown -R 150:150 /intershop/sites"]
    volumeMounts:
    - name: sites-volume
      mountPath: /intershop/sites
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

{{/*
Creates the volumes used by an ICM
*/}}
{{- define "icm-as.volumes" }}
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
  {{- if hasKey .Values.environment "STAGING_SYSTEM_TYPE" }}
  {{- if eq .Values.environment.STAGING_SYSTEM_TYPE "editing" }}
- name: replication-volume
  configMap:
    name: {{ template "icm-as.fullname" . }}-replication-clusters-xml
  {{- end }}
  {{- end }}
  {{- if .Values.persistence.customdata.enabled }}
- name: custom-data-volume
  persistentVolumeClaim:
    claimName: "{{ .Values.persistence.customdata.existingClaim }}"
  {{- end }}
- name: customizations-volume
  emptyDir: {}
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