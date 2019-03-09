# Provision NFS PVC for a namespace (backup-pvc-apb)

Welcome to the NFS Provision workspace.  This apb is designed to fully provision an external (to cluster) nfs share along with the cluster objects (pv/pvc) into a cluster namespace.

## How to Use

### Provision via GUI catalog

The backup volume (via NFS) is not provisioned in the same way that the gluster-file and gluster-block is provisioned.  Instead of provisioning via a claim request, you will order an NFS Volume as a catalog item.  You are not able to specify the name of the final PVC, one will be generated for you.

[Catalog Ordering (GUI)](docs/usage-gui.md)

### Provision via `svcat cli`

The Service Catalog CLI is a Kubernetes cli tool for interacting directly with the Service Catalog.  Using this tool will allow command-line provisioning of the NFS PVC Service Catalog item if you prefer.  

- Windows - [https://download.svcat.sh/cli/latest/windows/amd64/svcat.exe]
- linux - [https://download.svcat.sh/cli/latest/linux/amd64/svcat]
- darwin|macos - [https://download.svcat.sh/cli/latest/darwin/amd64/svcat]

``` bash
> svcat provision [service-instance-name] --class localregistry-backup-pvc-apb --plan default --params-json '{"rq_size":[size-in-Gb]}' -n [project-namespace]
```

## Verify your PVC

```bash
oc -n [project-namespace] get pvc
oc -n [project-namespace] get serviceInstance
```

You can tell which PVC is associated with the serviceInstance as the serviceInstance name is included in the PVC name.

## Removing your PVC

1. Ensure PVC is not mounted in any pods
2. Delete ServiceInstance that was provisioned

`Due to a current issue with the Automation-Broker, please inform ocp-lab-ops slack channel ASAP (@jefkel) of errors during a deprovision.  (include project name and ServiceInstance name in the slack message)`

## Other Documentation

- [Deployment](docs/Deployment.md)
- [Secrets](docs/Secrets.md)
