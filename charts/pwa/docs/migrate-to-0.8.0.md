# Migration to 0.8.0

## Simplified Ingress Declarations

The `ingress` and `ingresssplit` configurations were combined to only support one `ingress` object that can declare multiple instances.
We also dropped support for supplying paths because it is not working for the PWA standard deployment.

> [!IMPORTANT]
> When migrating from a previous PWA Helm Chart version to 0.8.0 it is important to remove the existing Ingress object from the cluster beforehand.
> Because of the differently configured path configuration in the template it cannot be updated but needs to be recreated.
> Please contact the OPS department for that.
>
> This is not relevant for new deployments, only for existing Ingress objects that are migrated.

With this changed `ingress` declaration format a basic `ingress` configuration looks like the following example.

```yaml
ingress:
  enabled: true
  className: nginx
  instances:
    ingress:
      annotations:
        kubernetes.io/tls-acme: "false"
      tlsSecretName: tls-star-pwa-intershop-de
      hosts:
        - host: pwa.example.local
```
A configuration example for the new `ingress` declaration format with host specific `tlsSecretName` overrides is as follows.

```yaml
ingress:
  enabled: true
  className: nginx
  instances:
    ingress:
      annotations:
        kubernetes.io/tls-acme: "false"
      tlsSecretName: tls-star-pwa-intershop-de
      hosts:
        - host: pwa.example.local
        - host: store.example.local
          tlsSecretName: store.tls-star-pwa-intershop-de
        - host: else.example.local
          tlsSecretName: else.tls-star-pwa-intershop-de
```


The migration from the previous `ingress` and `ingresssplit` configurations can be seen in the examples below.

__Old__

```yaml
ingress:
  enabled: true
  className: nginx
  annotations:
    kubernetes.io/tls-acme: "false"
  hosts:
    - host: pwa.example.local
      paths:
        - path: /
          pathType: ImplementationSpecific
  tls:
    - secretName: tls-star-pwa-intershop-de

ingresssplit:
  enabled: true
  className: nginx
  annotations:
    kubernetes.io/tls-acme: "false"
    configuration-snippet: |-
      satisfy any;
      allow xxx.xxx.xxx.xxx;
      deny all;
  hosts:
    - host: pwa-test.example.local
      paths:
        - path: /
          pathType: ImplementationSpecific
    - host: pwa2-test.example.local
      paths:
        - path: /
          pathType: ImplementationSpecific
  tls:
    - secretName: tls-star-pwa-intershop-de
```

__New__

```yaml
ingress:
  enabled: true
  className: nginx
  instances:
    ingress:
      annotations:
        kubernetes.io/tls-acme: "false"
      tlsSecretName: tls-star-pwa-intershop-de
      hosts:
        - host: pwa.example.local
    ingresssplit:
      annotations:
        kubernetes.io/tls-acme: "false"
        configuration-snippet: |-
          satisfy any;
          allow xxx.xxx.xxx.xxx;
          deny all;
      tlsSecretName: tls-star-pwa-intershop-de
      hosts:
        - host: pwa-test.example.local
        - host: pwa2-test.example.local
```

## Removed Handling of older Kubernetes Clusters

Please pay attention to which API version of networking.k8s.io you are using.
Check [this document](/charts/pwa/docs/migrate-to-0.3.0.md) for differences between the implementations.
For the sake of chart readability the PWA Helm Chart 0.8.0 only supports the new api-version [networking.k8s.io/v1](http://networking.k8s.io/v1).

## Configurable Update Strategy with default `RollingUpdate`

With the PWA Helm Chart 0.8.0 the `updateStrategy` for the deployments can be changed from the default `RollingUpdate` strategy to the alternative `Recreate` strategy.
Using `Recreate` better suites the dependency of first updating the SSR container and afterwards updating the NGINX container.
This might lead to a small downtime but prevents the NGINX from caching outdated SSR results that might lead to 404 errors for no longer existing Javascript files.
