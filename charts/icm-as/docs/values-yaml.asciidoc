# Documentation about what can be configured using the `values.yaml`-file

## State of this document

> Currently this document is created and filled with new content. So it is by far not a complete documentation!

## Sections

The following table gives a short overview about the different sections.

| Section                       | Topic                                                  |
| ----------------------------- | ------------------------------------------------------ |
| nodeSelector                  | agent pool assignment                                  |
| deploymentAnnotations         | annotations for deployment                             |
| podAnnotations                | annotations for pods                                   |
| podBindings                   | pod bindings                                           |
| deploymentLabels              | labels for deployment                                  |
| podLabels                     | labels for pods                                        |
| image                         | icm-as image configuration                             |
| dockerSecret                  | deployment of a docker registry secret                 |
| imagePullSecrets              | image pull secrets                                     |
| customizations                | customizations to be deployed                          |
| jvm                           | icm-as jvm configuration                               |
| newrelic                      | newrelic configuration                                 |
| infrastructureMonitoring      | infrastructure monitoring configuration                |
| operationalContext            | operational context configuration                      |
| serviceAccount                | service account to be deployed                         |
| podSecurityContext            | pod security context                                   |
| dnsConfig                     | dns configuration                                      |
| testConnection                | test connection configuration                          |
| resources                     | resources / limits configuration                       |
| database                      | database configuration                                 |
| environment                   | environment variables                                  |
| secrets                       | secrets to be made available as environment variables  |
| [secretMounts](#secretMounts) | secrets to be mounted as files / environment variables |
| persistence                   | persistence / volumes configuration                    |
| probes                        | probes (startup, liveness, readiness) configuration    |
| mssql                         | deployment of an MSSQL database inside a pod           |
| copySitesDir                  | copy sites directory                                   |
| ingress                       | ingress configuration                                  |
| webLayer                      | web layer (webadapter-replacement) configuration       |
| sslCertificateRetrieval       | ssl certificate retrieval                              |
| job                           | job server configuration                               |
| replication                   | replication/staging configuration                      |
| jgroups                       | jgroups configuration                                  |
| tolerations                   | pod tolerations configuration                          |

# secretMounts

> _@Since 2.9.0_

## Description

Allows the content of Kubernetes secrets to be mounted as files or made available as environment variables to the icm-as-server container.
The `secretMounts` section is a list of objects containing the following attributes:

| Attribute  | Description                                                                              | Type                           | Mandatory/Optional             | Default Value                   |
| ---------- | ---------------------------------------------------------------------------------------- | ------------------------------ | ------------------------------ | ------------------------------- |
| secretName | the name of the secret                                                                   | string                         | mandatory                      | -                               |
| type       | the type of the secret                                                                   | enum {`secret`, `certificate`} | optional                       | `secret`                        |
| key        | the data field inside the secret                                                         | string                         | optional if `type=certificate` | `tls.crt` if `type=certificate` |
| targetFile | path relative to `/secrets` if `type=secret` resp. `/certificates` if `type=certificate` | path                           | optional                       | -                               |
| targetEnv  | name of the environment variable to get made available                                   | string                         | optional                       | -                               |

> **Attention**: If neither `targetFile` nor `targetEnv` is set, the `secretMounts`-entry will have no effect at all.

> **Attention**: `certificate`s are imported into the truststore of the `icm-as-server`-container's JVM. So it is available to validate SSL/TLS connections to other servers that use this certificate.

## Example

```yaml
secretMounts:
  - secretName: my-secret
    type: secret
    targetFile: my-secret.txt
  - secretName: my-certificate
    type: certificate
    key: tls.crt
    targetFile: my-certificate-file.crt
  - secretName: my-certificate
    type: certificate
    key: tls.key
    targetFile: my-certificate-file.key
  - secretName: my-secret2
    type: secret
    targetEnv: MY_SECRET2
    targetFile: my-secret2.txt
```

- mounts the 3 secrets `my-secret`, `my-certificate` and `my-secret-env`:
  - `my-secret` is mounted as file `/secrets/my-secret.txt`
  - the certificate part of `my-certificate` is mounted as file `/certificates/my-certificate-file.crt`
  - the private key part of `my-certificate` is mounted as file `/certificates/my-certificate-file.key`
  - `my-secret2` is made available as environment variable `MY_SECRET2` and mounted as file `/secrets/my-secret2.txt`

Minimal variation of the above example (omitting optional attributes):

```yaml
secretMounts:
  - secretName: my-secret
    targetFile: my-secret.txt
  - secretName: my-certificate
    type: certificate
    targetFile: my-certificate-file.crt
  - secretName: my-certificate
    type: certificate
    key: tls.key
    targetFile: my-certificate-file.key
  - secretName: my-secret2
    targetEnv: MY_SECRET2
    targetFile: my-secret2.txt
```

> **Note**: See [Guide - Secret Store Process](https://support.intershop.com/kb/index.php/Display/X31381) for details on how to make secrets and certificates from an Azure KeyVault available in K8s secrets.
