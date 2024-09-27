{{/* vim: set filetype=mustache: */}}
{{/*
Creates init-containers
*/}}
{{- define "icm-as.infrastructureMonitoringContainer" -}}
{{- if .Values.infrastructureMonitoring.enabled }}
- name: infrastructure-monitoring
  image: {{ .Values.infrastructureMonitoring.image.repository }}
  imagePullPolicy: {{ .Values.infrastructureMonitoring.image.pullPolicy | default "IfNotPresent" }}
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
    value: "{{- include "icm-as.infrastructureMonitoringContainer.probeOpts" (set .Values.infrastructureMonitoring.databaseLatency "probeName" "databaseLatency") }}"
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
{{ include "icm-as.infrastructureMonitoringContainer.k8sProbe" (list "started" 3 30 5) }}
{{ include "icm-as.infrastructureMonitoringContainer.k8sProbe" (list "live" 3 10 5) }}
{{ include "icm-as.infrastructureMonitoringContainer.k8sProbe" (list "ready" 3 10 5) }}
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
creates an infrastructure probe configuration
expecting to get called like:
  - name: JAVA_OPTS_APPEND
    value: {{- include "icm-as.infrastructureMonitoringContainer.probeOpts" (set .Values.infrastructureMonitoring.databaseLatency "probeName" "databaseLatency") | indent 1 }}
replace:  '.Values.infrastructureMonitoring.databaseLatency' by the probe's values
          "databaseLatency" by the probe's name
*/}}
{{- define "icm-as.infrastructureMonitoringContainer.probeOpts" -}}
{{- printf "-Dprobes.%s.enabled=%t -Dprobes.%s.interval=%s" .probeName .enabled .probeName .interval -}}
{{- end -}}
