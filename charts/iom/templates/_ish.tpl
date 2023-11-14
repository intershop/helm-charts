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