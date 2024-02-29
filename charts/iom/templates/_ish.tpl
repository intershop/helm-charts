{{/*
The name of the auto-generated JWT secret and name of the according key need to be known in
different places, therefore they are defined centrally.
*/}}

{{- define "iom.jwt-auto-secret-name" -}}
{{ printf "%s-%s" (include "iom.fullname" .) "jwt-auto-secret" }}
{{- end }}

{{- define "iom.jwt-auto-secret-key" -}}
jwt-auto-secret
{{- end }}

{{/*
Helm annotations, that were complained to be missing when upgrading persistent-volume-claims.
*/}}
{{- define "meta.helm.annotations" -}}
meta.helm.sh/release-namespace: {{ .Release.Namespace }}
meta.helm.sh/release-name:  {{ .Release.Name }}
{{- end }}