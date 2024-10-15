{{/* vim: set filetype=mustache: */}}
{{/*
Creates init-containers
*/}}
{{- define "icm-as.infrastructureMonitoringContainer" -}}
{{- if .Values.infrastructureMonitoring.enabled }}
- name: infrastructure-monitoring
  image: {{ .Values.infrastructureMonitoring.image.repository }}
  imagePullPolicy: {{ .Values.infrastructureMonitoring.imagePullPolicy | default "IfNotPresent" }}
  env:
  {{- if .Values.mssql.enabled }}
  - name: QUARKUS_DATASOURCE_JDBC_URL
    value: {{ printf "jdbc:sqlserver://%s-mssql-service:1433;database=%s;TrustServerCertificate=True;" (include "icm-as.fullname" .) .Values.mssql.databaseName }}
  - name: QUARKUS_DATASOURCE_USERNAME
    value: "{{ .Values.mssql.user }}"
{{ include "icm-as.envDatabasePassword" (list "QUARKUS_DATASOURCE_PASSWORD" .Values.mssql.passwordSecretKeyRef .Values.mssql.password) | indent 2 }}
  {{- else }}
  - name: QUARKUS_DATASOURCE_JDBC_URL
    {{ if regexMatch ".+;$" .Values.database.jdbcURL -}}
    value: "{{ .Values.database.jdbcURL }}TrustServerCertificate=True;"
    {{- else -}}
    value: "{{ .Values.database.jdbcURL }};TrustServerCertificate=True;"
    {{- end }}
  - name: QUARKUS_DATASOURCE_USERNAME
    value: "{{ .Values.database.jdbcUser }}"
{{ include "icm-as.envDatabasePassword" (list "QUARKUS_DATASOURCE_PASSWORD" .Values.database.jdbcPasswordSecretKeyRef .Values.database.jdbcPassword) | indent 2 }}
  {{- end }}
  - name: JAVA_OPTS_APPEND
    value: '{{ include "icm-as.infrastructureMonitoringContainer.commonProbeOpts" (list .Values.infrastructureMonitoring.databaseLatency (dict "name" "databaseLatency" "type" "JDBC_LATENCY")) }} {{ include "icm-as.infrastructureMonitoringContainer.fsProbeOpts" (list .Values.infrastructureMonitoring.sitesLatency (dict "name" "sitesLatency" "type" "FILE_SYSTEM_LATENCY")) }} {{ include "icm-as.infrastructureMonitoringContainer.fsTpProbeOpts" (list .Values.infrastructureMonitoring.sitesReadThroughput (dict "name" "sitesReadThroughput" "type" "FILE_SYSTEM_READ_THROUGHPUT")) }} {{ include "icm-as.infrastructureMonitoringContainer.fsTpProbeOpts" (list .Values.infrastructureMonitoring.sitesWriteThroughput (dict "name" "sitesWriteThroughput" "type" "FILE_SYSTEM_WRITE_THROUGHPUT")) }}'
  ports:
  - name: inframonitoring
    containerPort: 8080
    protocol: TCP
  resources:
    limits:
      cpu: 100m
      memory: 200Mi
    requests:
      cpu: 100m
      memory: 200Mi
{{ include "icm-as.volumeMounts" . | indent 2 }}
{{ include "icm-as.infrastructureMonitoringContainer.k8sProbe" (list "started" 3 60 10) }}
{{ include "icm-as.infrastructureMonitoringContainer.k8sProbe" (list "live" 3 30 10) }}
{{ include "icm-as.infrastructureMonitoringContainer.k8sProbe" (list "ready" 3 30 10) }}
{{- end }}
{{- end -}}

{{/*
creates a K8s probe configuration (startup, liveness, readiness)
expecting to get called like:
{{ include "icm-as.infrastructureMonitoringContainer.k8sProbe" (list "<type>" <failureThreshold> <initialDelaySeconds> <periodSeconds>) }}
with
  <type>: one of [started, live, ready]
  <failureThreshold>: failure threshold (count)
  <initialDelaySeconds>: initial delay (seconds)
  <periodSeconds>: period (seconds)
*/}}
{{- define "icm-as.infrastructureMonitoringContainer.k8sProbe" -}}
{{- $type := index . 0 }}
{{- $failureThreshold := index . 1 }}
{{- $initialDelaySeconds := index . 2 }}
{{- $periodSeconds := index . 3 }}
{{- if eq $type "started" }}
  startupProbe:
{{- else if eq $type "live" }}
  livenessProbe:
{{- else }}
  readinessProbe:
{{- end }}
    httpGet:
      path: /q/health/{{ $type }}
      port: inframonitoring
    failureThreshold: {{ $failureThreshold }}
    initialDelaySeconds: {{ $initialDelaySeconds }}
    periodSeconds: {{ $periodSeconds }}
{{- end -}}

{{/*
creates an infrastructure probe configuration (common options)
expecting to get called like:
  - name: JAVA_OPTS_APPEND
    value: '{{ include "icm-as.infrastructureMonitoringContainer.commonProbeOpts" (list .Values.infrastructureMonitoring.databaseLatency (dict "name" "databaseLatency" "type" "JDBC_LATENCY")) }}'
replace:  '.Values.infrastructureMonitoring.databaseLatency' by the probe's values
          "databaseLatency" by the probe's name
          "JDBC_LATENCY" by the probe's type
*/}}
{{- define "icm-as.infrastructureMonitoringContainer.commonProbeOpts" -}}
{{- $probeValues := index . 0 }}
{{- $probeOpts := index . 1 }}
{{- $probeName := $probeOpts.name }}
{{- $isEnabled := default false $probeValues.enabled }}
{{- $probeType := $probeOpts.type }}
{{- if $isEnabled -}}
{{- printf "-Dprobes.%s.enabled=%t -Dprobes.%s.type=%s -Dprobes.%s.interval=%s" $probeName $isEnabled $probeName (quote $probeType) $probeName (quote (default "60S" $probeValues.interval)) -}}
{{- else -}}
{{- printf "-Dprobes.%s.enabled=%t" $probeName $isEnabled -}}
{{- end -}}
{{- end -}}

{{/*
creates an infrastructure probe configuration (file system related options)
expecting to get called like:
  - name: JAVA_OPTS_APPEND
    value: '{{ include "icm-as.infrastructureMonitoringContainer.fsProbeOpts" (list .Values.infrastructureMonitoring.sitesLatency (dict "name" "sitesLatency" "type" "FILE_SYSTEM_LATENCY")) }}'
replace:  '.Values.infrastructureMonitoring.sitesLatency' by the probe's values
          "sitesLatency" by the probe's name
          "FILE_SYSTEM_LATENCY" by the probe's type
*/}}
{{- define "icm-as.infrastructureMonitoringContainer.fsProbeOpts" -}}
{{- $probeValues := index . 0 }}
{{- $probeOpts := index . 1 }}
{{- $probeName := $probeOpts.name }}
{{- $isEnabled := default false $probeValues.enabled }}
{{- $path := $probeValues.path }}
{{- include "icm-as.infrastructureMonitoringContainer.commonProbeOpts" (list $probeValues $probeOpts) }}{{- if $isEnabled }} {{ printf "-Dprobes.%s.path=%s" $probeName (quote $path) -}}{{- end -}}
{{- end -}}

{{/*
creates an infrastructure probe configuration (file system throughput related options)
expecting to get called like:
  - name: JAVA_OPTS_APPEND
    value: '{{ include "icm-as.infrastructureMonitoringContainer.fsThroughputProbeOpts" (list .Values.infrastructureMonitoring.sitesReadThroughput (dict "name" "sitesReadThroughput" "type" "FILE_SYSTEM_READ_THROUGHPUT")) }}'
replace:  '.Values.infrastructureMonitoring.sitesReadThroughput' by the probe's values
          "sitesReadThroughput" by the probe's name
          "FILE_SYSTEM_READ_THROUGHPUT" by the probe's type
*/}}
{{- define "icm-as.infrastructureMonitoringContainer.fsTpProbeOpts" -}}
{{- $probeValues := index . 0 }}
{{- $probeOpts := index . 1 }}
{{- $probeName := $probeOpts.name }}
{{- $isEnabled := default false $probeValues.enabled }}
{{- $fileSize := $probeValues.fileSize }}
{{- include "icm-as.infrastructureMonitoringContainer.fsProbeOpts" (list $probeValues $probeOpts) }}{{- if $isEnabled }} {{ printf "-Dprobes.%s.fileSize=%s" $probeName (quote (default "5 Mi" $fileSize)) -}}{{- end -}}
{{- end -}}
