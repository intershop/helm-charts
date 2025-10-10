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
environment-name: {{ include "icm-as.environmentName" . }}
operational-context: {{ include "icm-as.operationalContextName" . }}
{{ include "icm-as.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
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
    {{- default (include "icm-as.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
    {{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{/*
Azure Workload Identity environment variables
*/}}
{{- define "icm-as.managedIdentityEnv" -}}
{{- if .Values.managedIdentity.enabled }}
- name: AZURE_CLIENT_ID
  value: {{ .Values.managedIdentity.clientId | quote }}
{{- if .Values.managedIdentity.tenantId }}
- name: AZURE_TENANT_ID
  value: {{ .Values.managedIdentity.tenantId | quote }}
{{- end }}
- name: AZURE_FEDERATED_TOKEN_FILE
  value: "/var/run/secrets/azure/tokens/azure-identity-token"
{{- range .Values.managedIdentity.additionalEnvVars }}
- name: {{ .name }}
  value: {{ .value | quote }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
ConfigMap environment variables
*/}}
{{- define "icm-as.envFromConfigMap" -}}
{{- if .Values.envConfigMap.enabled }}
{{- if .Values.envConfigMap.existingConfigMap }}
- configMapRef:
    name: {{ .Values.envConfigMap.existingConfigMap }}
{{- else if .Values.envConfigMap.data }}
- configMapRef:
    name: {{ include "icm-as.fullname" . }}-env-config
{{- end }}
{{- end }}
{{- end -}}

{{/*
Azure Workload Identity volume mounts
*/}}
{{- define "icm-as.managedIdentityVolumeMounts" -}}
{{- if .Values.managedIdentity.enabled }}
- name: azure-identity-token
  mountPath: /var/run/secrets/azure/tokens
  readOnly: true
{{- end }}
{{- end -}}

{{/*
Azure Workload Identity volumes
*/}}
{{- define "icm-as.managedIdentityVolumes" -}}
{{- if .Values.managedIdentity.enabled }}
- name: azure-identity-token
  projected:
    defaultMode: 420
    sources:
    - serviceAccountToken:
        audience: api://AzureADTokenExchange
        expirationSeconds: 3600
        path: azure-identity-token
{{- end }}
{{- end -}}

{{/*
Create the values for the environment variable FEATURED_JVM_ARGUMENTS.
These are predefined parameter from several features.
*/}}
{{- define "icm-as.featuredJVMArguments" -}}
{{- $addVmOptions := list -}}
{{- $addVmOptions = append $addVmOptions .Values.jvm.options -}}
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
- name: ADDITIONAL_JVM_ARGUMENTS
  value: {{ join " " $addVmOptions | quote }}
{{- end -}}

{{/*
Creates a chart-label
*/}}
{{- define "icm-as.chartLabel" -}}
chart: "{{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}"
{{- end -}}

{{/*
Creates resources
*/}}
{{- define "icm-as.resources" -}}
resources: {{- toYaml .Values.resources | nindent 2 }}
{{- end -}}

{{/*
Pod-annotations
*/}}
{{- define "icm-as.podData" -}}
annotations:
  {{- if .Values.newrelic.metrics.enabled }}
  prometheus.io/scrape: 'true'
  {{- else }}
  prometheus.io/scrape: 'false'
  {{- end }}
  prometheus.io/port: '7744'
  prometheus.io/path: '/metrics'
  {{- if .Values.managedIdentity.enabled }}
  azure.workload.identity/use: "true"
  {{- if .Values.managedIdentity.clientId }}
  azure.workload.identity/client-id: {{ .Values.managedIdentity.clientId | quote }}
  {{- end }}
  {{- end }}
{{- if .Values.podAnnotations -}}
{{- toYaml .Values.podAnnotations | nindent 2 }}
{{- end }}
{{- end -}}

{{/*
Pod-labels
*/}}
{{- define "icm-as.podLabels" -}}
jgroupscluster: "{{- .Values.jgroups.clusterLabel | default .Release.Name -}}"
{{- with .Values.podLabels }}
{{- . | toYaml | nindent 0 }}
{{- end }}
{{- end -}}

{{/*
AAD Pod-binding label
*/}}
{{- define "icm-as.podBinding" -}}
{{- if .Values.podBinding.enabled }}
aadpodidbinding: {{ .Values.podBinding.binding }}
{{- end }}
{{- end -}}

{{/*
Node-selector
*/}}
{{- define "icm-as.nodeSelector" -}}
{{- if .Values.nodeSelector -}}
nodeSelector:
  {{- toYaml .Values.nodeSelector | nindent 2 }}
{{- end }}
{{- end -}}

{{/*
Node-tolerations
*/}}
{{- define "icm-as.tolerations" -}}
{{- if .Values.tolerations -}}
tolerations:
  {{- toYaml .Values.tolerations | nindent 2 }}
{{- end }}
{{- end -}}

{{/*
Image spec
*/}}
{{- define "icm-as.image" -}}
image: "{{ .Values.image.repository }}{{ if not (contains ":" .Values.image.repository) }}:{{ .Values.image.tag | default .Chart.AppVersion }}{{ end }}"
imagePullPolicy: "{{ .Values.image.pullPolicy | default "IfNotPresent" }}"
{{- end -}}

{{/*
Image SemVer release
*/}}
{{- define "icm-as.imageSemanticVersion" -}}
  {{- if contains ":" .Values.image.repository -}}
    {{- splitList ":" .Values.image.repository | last | trim -}}
  {{- else -}}
    {{- .Values.image.tag | default .Chart.AppVersion -}}
  {{- end -}}
{{- end -}}

{{/*
imagePullSecrets spec
*/}}
{{- define "icm-as.imagePullSecrets" -}}
{{- if .Values.imagePullSecrets -}}
imagePullSecrets:
{{- range .Values.imagePullSecrets }}
- name: {{ . | quote }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Applies security context information
*/}}
{{- define "icm-as.podSecurityContext" -}}
{{- if .Values.podSecurityContext -}}
securityContext:
  {{- toYaml .Values.podSecurityContext | nindent 2 }}
{{- end }}
{{- end -}}

{{/*
Add entries to a Pod's /etc/hosts
*/}}
{{- define "icm-as.hostAliases" -}}
{{- if .Values.hostAliases -}}
hostAliases:
  {{- toYaml .Values.hostAliases | nindent 2 }}
{{- end }}
{{- end -}}

{{/*
Customize DNS configuration
*/}}
{{- define "icm-as.dnsConfig" -}}
{{- if .Values.dnsConfig -}}
dnsConfig:
  {{- toYaml .Values.dnsConfig | nindent 2 }}
{{- end }}
{{- end -}}

{{/*
The discovery mode of jgroups messaging
*/}}
{{- define "icm-as.jgroups.discovery" -}}
{{- if .Values.jgroups -}}
  {{- if .Values.jgroups.discovery -}}
    {{- .Values.jgroups.discovery -}}
  {{- else -}}
    {{- printf "file_ping" }}
  {{- end -}}
{{- else -}}
    {{- printf "file_ping" }}
{{- end -}}
{{- end -}}

{{/*
Whether replication uses the new configuration
*/}}
{{- define "icm-as.replicationUsesNewConfiguration" -}}
  {{- if .Values.replication.enabled -}}
    {{- $hasNewReplicationConfiguration := or (hasKey .Values.replication "source") (hasKey .Values.replication "targets") -}}
    {{- $hasNewReplicationConfiguration -}}
  {{- else -}}
    false
  {{- end -}}
{{- end -}}

{{/*
Whether replications' replication-clusters.xml configuration is used
*/}}
{{- define "icm-as.replicationUsesReplicationClustersXmlConfiguration" -}}
  {{- if .Values.replication.enabled -}}
    {{- $hasDeprecatedReplicationConfiguration := include "icm-as.replicationUsesNewConfiguration" . | eq "false" -}}
    {{- and ($hasDeprecatedReplicationConfiguration) (eq .Values.replication.role "source") -}}
  {{- else -}}
    false
  {{- end -}}
{{- end -}}

{{/*
Handle the command for the icm-as container.
*/}}
{{- define "icm-as.command" -}}
  {{- $customCommand := index . 0 }}
  {{- $isAsDeployment := index . 1 }}
  {{- if and ($customCommand) ($isAsDeployment) -}}
  command:
    {{- toYaml $customCommand | nindent 2 }}
  {{- else -}}
  command:
  - /bin/bash
  - -c
  - |
    source /__cacert_entrypoint.sh && \
    ADDITIONAL_JVM_ARGUMENTS="${ADDITIONAL_JVM_ARGUMENTS} ${JAVA_TOOL_OPTIONS}" && \
    printf '%.0s-' {1..80} && \
    echo && \
    /intershop/bin/intershop.sh
  {{- end }}{{/* if .Values.customCommand */}}
{{- end -}}{{/* define "icm-as.command" */}}
