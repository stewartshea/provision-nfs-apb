# Provision backup (NFS) PVC for project (backup-pvc-apb)

## Provision Needs

1. Create remote nfs shared lv (thin volume)
2. Create PV and PVC in target namespace for created nfs share.

## Deprovision Needs

1. Delete PVC and reclaim/delete PV (do not keep)
2. Remove NFS Share and volume (avoid orphans)

## TBD

1. do not automatically delete nfs pv and contents?
2. check quota before provisioning?

## Deployment Steps

### Build/Push APB Image to openshift project

Local package requirements: oc client, apb cli, local docker

`oc login` (user needs edit/admin permissions within 'openshift' and 'openshift-ansible-service-broker' namespaces)

`oc get route docker-registry -n default`

`export OSC_DOCKER_REG=docker-registry.lab.pathfinder.gov.bc.ca`

confirm /etc/containers/registries.conf has insecure route (if needed)

- add to [registries.insecure] section:
  `registries = [${OSC_DOCKER_REG}]`

This apb was created with "apb init", and can be pushed via the following (in the top folder):

``` bash
apb prepare
apb build --tag ${OSC_DOCKER_REG}/openshift/backup-pvc-apb
apb push --registry-route ${OSC_DOCKER_REG}

# Verify apb (note: svcat may take up to 10 minutes to show up due to catalog refresh timer):
oc get images -n openshift | grep backup-pvc-apb
svcat sync broker ansible-service-broker
svcat get plans | grep backup-pvc
```

### Update openshift-ansible-service-broker

Create service account with cluster storage admin role.

``` bash
oc create sa {PVServiceAcctName} -n openshift-ansible-service-broker
oc adm policy add-cluster-role-to-user system:controller:persistent-volume-binder system:serviceaccount:openshift-ansible-service-broker:{PVServiceAcctName}
```

Ensure service account created on NFS host with SSH Key access and passwordless sudo for ansible automation.

Add an opaque secret using the parameter-secret.json.sample as a template.

create secret with : `oc create -f parameter-secret.json`
(it will base64 encode items listed in "stringData" section, or if you have base64 encoded values, put them in a data section instead)

``` json
apiVersion: v1
kind: Secret
metadata:
    name: {bkup-nfs-param secret name}
    namespace: openshift-ansible-service-broker
stringData:
    "backup_storage_nfs_server": {nfshost.domain.name}
    "backup_storage_nfs_root": {/path/to/nfs/export/root}
    "backup_storage_volumegroup": {LVG name}
    "backup_storage_thinpool": {lv thinpool name}
    "remote_user": {remote nfs host user}
    "auth_key": {sshkey auth for remote_user}
    "pv_srv_acct": {PVServiceAcctName}
    "pv_srv_acct_token": {Auth Token for PVServiceAcctName}
```

Update cm/broker-config with the following changes:

``` yaml
Add section:
  secrets:
  - title: backup-nfs-auth
    apb_name: localregistry-backup-pvc-apb
    secret: {bkup-nfs-param secret name}
```

Redeploy openshift-ansible-service-broker to use new cm/broker-config

Test creating serviceInstance. (Should only see project and size as parameters)
