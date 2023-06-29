# Helm Chart Intershop Commerce Management - Job Server

This chart bring job server functionality into the [ICM Application Server](../icm-as/README.md) (`icm-as`). If enabled long running jobs could run outside of the application server as kubernetes jobs.

It will install the ICMJob-CRD (Custom Resource Definition) per default. If the ICMJob-CRD already exists, it will be skipped with a warning. If you wish to skip this CRD installation step, you can pass the `--skip-crds` flag to the `helm install/upgrade` command. Note that uninstalling this chart will *NOT* uninstall the CRD. In order to uninstall the ICMJob-CRD use:

```bash
kubectl delete -f crds/icm-job-controller.yaml
```