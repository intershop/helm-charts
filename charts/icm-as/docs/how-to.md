# What has to be done to reach a certain goal

## Make a custom TLS certificate available to the `icm-as-server`-container's JVM

1. Follow [Guide - Secret Store Process](https://support.intershop.com/kb/index.php/Display/X31381) to create a secret in the K8s cluster using a certificate stored inside an Azure Key Vault.
2. Add an entry inside the [secretMounts](#secretMounts)-section

   - reference the secret created from step 1
   - set `type` to `certificate`
   - set `key` to `tls.crt` or omit the `key`
   - set `targetFile` to a valid file name using the file extension `.crt`

   > The certificate will then be imported into the truststore of the JVM using the alias built from the base file name.
