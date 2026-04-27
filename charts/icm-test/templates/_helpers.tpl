{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "icm-test.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the service account to use.
*/}}
{{- define "icm-test.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "icm-test.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}


{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "icm-test.fullname" -}}
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
Create the fullname of the nested icm-as release.
*/}}
{{- define "icm-test.icmAsFullname" -}}
{{- $icmAsValues := index .Values.icm "icm-as" -}}
{{- if $icmAsValues.fullnameOverride -}}
{{- $icmAsValues.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "icm-as" $icmAsValues.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create the MSSQL service name of the nested icm-as release.
*/}}
{{- define "icm-test.icmAsMssqlServiceName" -}}
{{- printf "%s-mssql-service" (include "icm-test.icmAsFullname" .) -}}
{{- end -}}

{{/*
Create the MSSQL backup claim name of the nested icm-as release.
*/}}
{{- define "icm-test.icmAsMssqlBackupClaimName" -}}
{{- $icmAsValues := index .Values.icm "icm-as" -}}
{{- if eq $icmAsValues.mssql.persistence.backup.type "local" -}}
{{- printf "%s-local-mssql-db-backup-pvc" (include "icm-test.icmAsFullname" .) -}}
{{- else if eq $icmAsValues.mssql.persistence.backup.type "existingClaim" -}}
{{- $icmAsValues.mssql.persistence.backup.existingClaim -}}
{{- else if eq $icmAsValues.mssql.persistence.backup.type "nfs" -}}
{{- printf "%s-nfs-mssql-db-backup-pvc" (include "icm-test.icmAsFullname" .) -}}
{{- else if eq $icmAsValues.mssql.persistence.backup.type "cluster" -}}
{{- printf "%s-cluster-mssql-db-backup-pvc" (include "icm-test.icmAsFullname" .) -}}
{{- else -}}
{{- "" -}}
{{- end -}}
{{- end -}}

{{/*
Create the sites PVC claim name of the nested icm-as release.
*/}}
{{- define "icm-test.icmAsSitesClaimName" -}}
{{- $icmAsValues := index .Values.icm "icm-as" -}}
{{- if eq $icmAsValues.persistence.sites.type "local" -}}
{{- printf "%s-local-sites-pvc" (include "icm-test.icmAsFullname" .) -}}
{{- else if eq $icmAsValues.persistence.sites.type "existingClaim" -}}
{{- $icmAsValues.persistence.sites.existingClaim -}}
{{- else if eq $icmAsValues.persistence.sites.type "nfs" -}}
{{- printf "%s-nfs-sites-pvc" (include "icm-test.icmAsFullname" .) -}}
{{- else if eq $icmAsValues.persistence.sites.type "cluster" -}}
{{- printf "%s-cluster-sites-pvc" (include "icm-test.icmAsFullname" .) -}}
{{- else if eq $icmAsValues.persistence.sites.type "azurefiles" -}}
{{- "" -}}
{{- else -}}
{{- printf "%s-static-sites-pvc" (include "icm-test.icmAsFullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "icm-test.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the values for the environment variable FEATURED_JVM_ARGUMENTS.
These are predefined parameter from serveral features.
*/}}
{{- define "icm-test.testrunner.featuredJVMArguments" -}}
    {{- $addVmOptions := list -}}
    {{- $addVmOptions = append $addVmOptions .Values.testrunner.jvm.options -}}
- name: FEATURED_JVM_ARGUMENTS
  value: {{ join " " $addVmOptions | quote }}
{{- end -}}

{{/*
Create the values for the environment variable ADDITIONAL_JVM_ARGUMENTS.
These are additional parameters defined by deployment, which are not indented to override feature specific parameter.
*/}}
{{- define "icm-test.testrunner.additionalJVMArguments" -}}
    {{- $addVmOptions := list -}}
    {{- $addVmOptions = append $addVmOptions .Values.testrunner.jvm.additionalOptions -}}
- name: ADDITIONAL_JVM_ARGUMENTS
  value: {{ join " " $addVmOptions | quote }}
{{- end -}}

