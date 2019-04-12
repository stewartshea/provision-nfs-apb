# Introduction

The OpenShift Pathfinder Platform provides several types of storage for use within a project space.  If a project wants to have state data backed up within the BC Government Enterprise backup environment, the nfs-backup storageClass provides a staging area for projects to backup live application data to that will be accessible for team backup and restore requests.

## Pre-Requisites

As a staging area, the nfs-backup StorageClass is not Highly Available and is not recommended for hosting live application data directly.  The recommended approach is to have a specific (backup?) container that will run a custom application backup.  The [backup-container](https://github.com/bcdevops/backup-container) is a good example to use.

## Availability

There is a minimum quota of 5Gi and 2 PV's for each project.  This amount was deemed enough to create a proof of concept backup process for your projects.  Once you have a working process within your projects, you may want to request a more appropriate size (if the 5Gi does not meet your needs).  This process is still in development but aims to ensure that your backup process will not introduce problems for the platform or your project.  Reach out in #devops-requests for a backup process review and quota increase once your process is ready.

Maintenance and service issues for the NFS service are announced in [#devops-alerts](https://chat.pathfinder.gov.bc.ca/channel/devops-alerts) and [#devops-operations](https://chat.pathfinder.gov.bc.ca/channel/devops-operations) as with other Pathfinder operational efforts.

## Enterprise Backup/Restore Requests

Enterprise Backup/Restore requests (including customizing schedules, restores, etc) are currently accessed through normal restore request channels (ie: serviceDesk, 7700)  You will need to include the following information:

``` text
Server: OCIOPF-P-150.DMZ
Path: /srv/nfs/oscbkp/{volume-name}
```

`Volume name is the PVC name without the "bk-" prefix. (or the volume name for your nfs-backup PVC)`

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

Due to a current issue with the Automation-Broker, please inform [#devops-sos](https://chat.pathfinder.gov.bc.ca/channel/devops-sos) channel ASAP (@Jeff.arctiq) if you get errors during a deprovision.  (include project name and ServiceInstance name in the message)
