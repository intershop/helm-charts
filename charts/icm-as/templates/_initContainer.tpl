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
  image: busybox:1.36.1
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
{{- if and .Values.mssql.enabled .Values.dumpfileRestore.enabled }}
- name: db-restore-from-dumpfile
  image: "{{ .Values.dumpfileRestore.image.repository }}"
  imagePullPolicy: IfNotPresent
  command:
  - "/bin/bash"
  - "-c"
  - |
    set -e
    DUMPFILE_DIR="{{ .Values.dumpfileRestore.dumpfileDir }}"
    if [ ! -d "$DUMPFILE_DIR" ]; then
      echo "Dumpfile directory $DUMPFILE_DIR does not exist, skipping restore."
      exit 0
    fi
    DUMPFILE=$(find "$DUMPFILE_DIR" -maxdepth 1 \( -name "*.dmp" -o -name "*.bak" \) 2>/dev/null | head -1)
    if [ -z "$DUMPFILE" ]; then
      echo "No dumpfile found in $DUMPFILE_DIR, skipping restore."
      exit 0
    fi
    echo "Found dumpfile: $DUMPFILE"
    FILENAME=$(basename "$DUMPFILE")
    echo "Copying dumpfile to MSSQL backup volume..."
    cp "$DUMPFILE" /mssql-backup/
    echo "Dumpfile copied successfully."
    MSSQL_HOST="{{ include "icm-as.fullname" . }}-mssql-service"
    SA_PASSWORD="{{ .Values.mssql.saPassword }}"
    DB_NAME="{{ .Values.mssql.databaseName }}"
    echo "Waiting for MSSQL at $MSSQL_HOST to be ready..."
    for i in $(seq 1 {{ .Values.dumpfileRestore.waitTimeout }}); do
      /opt/mssql-tools/bin/sqlcmd -S "$MSSQL_HOST" -U sa -P "$SA_PASSWORD" -Q "SELECT 1" > /dev/null 2>&1
      if [ $? -eq 0 ]; then
        echo "MSSQL is ready after ${i}s."
        break
      fi
      if [ "$i" -eq {{ .Values.dumpfileRestore.waitTimeout }} ]; then
        echo "ERROR: MSSQL did not become ready within {{ .Values.dumpfileRestore.waitTimeout }}s."
        exit 1
      fi
      sleep 1
    done
    echo "Restoring database '$DB_NAME' from /var/opt/mssql/backup/$FILENAME..."
    /opt/mssql-tools/bin/sqlcmd -S "$MSSQL_HOST" -U sa -P "$SA_PASSWORD" -Q "RESTORE DATABASE [$DB_NAME] FROM DISK = N'/var/opt/mssql/backup/$FILENAME' WITH REPLACE"
    if [ $? -eq 0 ]; then
      echo "Database restore completed successfully."
      DB_USER="{{ .Values.mssql.user }}"
      DB_PASSWORD="{{ .Values.mssql.password }}"
      echo "Fixing database user mapping for $DB_USER..."
      /opt/mssql-tools/bin/sqlcmd -S "$MSSQL_HOST" -U sa -P "$SA_PASSWORD" -Q "USE [$DB_NAME]; IF NOT EXISTS (SELECT name FROM master.sys.server_principals WHERE name = '$DB_USER') BEGIN CREATE LOGIN [$DB_USER] WITH PASSWORD = '$DB_PASSWORD', CHECK_POLICY = OFF END; IF NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = '$DB_USER') BEGIN CREATE USER [$DB_USER] FOR LOGIN [$DB_USER] END ELSE BEGIN ALTER USER [$DB_USER] WITH LOGIN = [$DB_USER] END; ALTER ROLE [db_owner] ADD MEMBER [$DB_USER];"
    else
      echo "ERROR: Database restore failed."
      exit 1
    fi
  volumeMounts:
  {{- if .Values.persistence.customdata.enabled }}
  - name: custom-data-volume
    mountPath: {{ .Values.persistence.customdata.mountPoint | default "/data" }}
  {{- end }}
  - name: mssql-backup-volume
    mountPath: /mssql-backup
  securityContext:
    runAsUser: 0
{{- end }}
{{- end -}}
