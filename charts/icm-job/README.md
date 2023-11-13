# Helm Chart Intershop Commerce Management - Job Server

This chart brings job server functionality into the [ICM Application Server](../icm-as/README.md) (`icm-as`). If enabled long running jobs could run outside of the application server as kubernetes jobs.

## Initial Deployment

```bash
helm upgrade --install icm-job icm-job -n icm-system
```

## Redeployment of Custom Resource Definition

The chart will install the ICMJob-CRD (Custom Resource Definition) per default. If the ICMJob-CRD already exists, it will be skipped with a warning. If you wish to skip this CRD installation step, you can pass the `--skip-crds` flag to the `helm install/upgrade` command. Note that uninstalling this chart will *NOT* uninstall the CRD. In order to uninstall the ICMJob-CRD use:

```bash
kubectl delete -f crds/icm-job-controller.yaml
```

## Remove Deployment

Removing the helm release will remove the controller and the installed resources, like services, service account, roles and bindings.
But, the Custom Resource Definition will stay and needs to be removed manually if needed.

```bash
helm delete icm-job -n icm-system
kubectl delete -f crds/icm-job-controller.yaml
```
