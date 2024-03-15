{{- define "edusharing.dockerconfigjson" }}
{{- printf "{\"auths\":{\"%s\":{\"username\":\"%s\",\"password\":\"%s\",\"auth\":\"%s\"}}}" .server .username .password (printf "%s:%s" .username .password | b64enc) | b64enc }}
{{- end }}
