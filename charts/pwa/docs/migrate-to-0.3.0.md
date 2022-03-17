# Migration to 0.3.0

## What Is the Current Behavior?
Depending on the Kubernetes version you are using, the definition of ingress resources has to be changed. If you are using Kubernetes version >= 1.19, ingress resources are now using api-version [networking.k8s.io/v1](http://networking.k8s.io/v1). Older versions of PWA Helm charts always used api-version [networking.k8s.io/v1beta1](http://networking.k8s.io/v1beta1). Therefore, warnings like this appeared when installing the PWA in Kubernetes:
```
Warning:  templates/ingress.yaml: extensions/v1beta1 Ingress is deprecated in v1.14+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress
```

## What Is the New Behavior?

We are using the new api-version [networking.k8s.io/v1](http://networking.k8s.io/v1). Depending on your Kubernetes version, we fall back to the previous (now outdated) api-version [networking.k8s.io/v1beta1](http://networking.k8s.io/v1beta1). You have to migrate `values.yaml` according to these small examples:

Old:
```yaml
ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: nginx
  paths: ["/"]
  hosts:
    - pwa.example.local
```
Migrated:
```yaml
ingress:
  enabled: true
  className: nginx
  annotations: {}
    # kubernetes.io/ingress.class: nginx
  hosts:
    - host: pwa.example.local
      paths:
        - path: /
          pathType: ImplementationSpecific
```
More information can be found in the [Deprecated API Migration Guide](https://kubernetes.io/docs/reference/using-api/deprecation-guide/) of Kubernetes and the [official documentation of the ingress API object](https://kubernetes.io/docs/concepts/services-networking/ingress/).
