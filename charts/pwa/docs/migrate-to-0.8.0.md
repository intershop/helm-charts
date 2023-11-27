# Migration to 0.8.0

## Simplified Ingress Declarations

The `ingress` and `ingresssplit` configurations were combined to only support one `ingress` object that can declare multiple instances.
We also dropped support for supplying paths because it is not working for the PWA standard deployment.

Old:

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

New:

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