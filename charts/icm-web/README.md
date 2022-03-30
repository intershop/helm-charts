# Helm Chart Intershop Commerce Management - Web Adapter and Web Adapter Agent

Installs the ICM web adapter and web adapter agent indepentently.

## TL;DR
Via command line:

```bash
$ helm repo add intershop https://intershop.github.io/helm-charts
$ helm repo update
$ helm install my-release intershop/icm-web --values=values.yaml --namespace icm
```

# Development

## Prerequisites

Verify installation of:
- helm
- kubectl
- kubernetes (e.g. can be enabled via docker for windows)


### Docker pull secret
Create a secret for a docker registry where the images are coming from. The name of the secret must be equal to the configured secrets under `agent.image.secret` and `webadapter.image.secret` within the application deployment. By default the secret name is `dockerhub`.

```bash
$ kubectl create secret docker-registry <yourDockerRegistryName> --docker-server=<yourDockerRegistryServer> --docker-username=<yourUsername> --docker-password=<yourPassword> --docker-email=<yourEmail>
```
