{{/*
Helm annotations, that were complained to be missing when upgrading persistent-volume-claims.
*/}}
{{- define "meta.helm.annotations" -}}
meta.helm.sh/release-namespace: {{ .Release.Namespace }}
meta.helm.sh/release-name:  {{ .Release.Name }}
{{- end }}