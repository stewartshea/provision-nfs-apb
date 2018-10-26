# Provision NFS PVC for a namespace (backup-pvc-apb)

Welcome to the NFS Provision workspace.  This apb is designed to fully provision an external (to cluster) nfs share along with the cluster objects (pv/pvc) into a cluster namespace.

## How to Use

### Provision via `svcat cli`

``` bash
> svcat provision [service-instance-name] --class localregistry-backup-pvc-apb --plan default --params-json '{"rq_size":[size-in-Gb]}' -n [project-namespace]
```

### View catalog item details

``` bash
> svcat describe plan localregistry-backup-pvc-apb/default
  Name:          default
  Description:   Provision an NFS backed PVC for the target project.  
  UUID:          5131dda39f778c1a979b9b9a2effbd15
  Status:        Active
  Free:          true
  Class:         localregistry-backup-pvc-apb

Instances:
                 NAME                  NAMESPACE   STATUS  
+------------------------------------+-----------+--------+
  localregistry-backup-pvc-apb-5lr9j   jeff-test   Ready

Instance Create Parameter Schema:
  $schema: http://json-schema.org/draft-04/schema
  additionalProperties: false
  properties:
    rq_size:
      default: 1
      title: Backup Volume Size (Gb)
      type: number
  required:
  - rq_size
  type: object

Instance Update Parameter Schema:
  $schema: http://json-schema.org/draft-04/schema
  additionalProperties: false
  type: object

Binding Create Parameter Schema:
  $schema: http://json-schema.org/draft-04/schema
  additionalProperties: false
  type: object
```

### Provision via GUI catalog

Simply click on the "BC Gov NFS Storage" catalog item and ensure parameters are entered as needed.  You cannot specify the name of the serviceInstance when provisioning through the GUI, one will be generated for you.

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

- Deployment(docs/Deployment.md)
- Secrets(docs/Secrets.md)
