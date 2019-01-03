# Deployment Steps

## Build/Push APB Image to openshift project

Local package requirements:

- oc client
- apb cli [https://docs.okd.io/3.10/apb_devel/cli_tooling.html](https://docs.okd.io/3.10/apb_devel/cli_tooling.html)
- local docker

`oc login` (as user with cluster-admin)

Create a build config to handle building of the image, then tag it over to the main openshift project:

``` bash
oc new-build https://github.com/BCDevOps/provision-nfs-apb.git --context-dir=backup-pvc-apb \
  --strategy=docker --name=backup-pvc-apb
oc logs -f bc/backup-pvc-apb
oc tag advsol-ops/backup-pvc-apb:latest openshift/backup-pvc-apb:latest
```

Run the following to bootstrap the broker and sync the catalog (instead of waiting for the timed bootstrap and sync)

``` bash
    oc get route -n openshift-ansible-service-broker
    curl -H "Authorization: Bearer $(oc whoami -t)" -k -X POST \
    https://$(oc get route -n openshift-ansible-service-broker | grep asb | awk -f '{print $2}')/ansible-service-broker/v2/bootstrap

    wait for bootstrap to complete, and then sync(relist) the catalog
    svcat sync broker ansible-service-broker
```

## Update openshift-ansible-service-broker

### Deploy openshift-ansible-service-broker and cluster objects

Update [deploy/templates/parameters.yaml](../deploy/templates/parameters.yaml) with the appropriate parameter values, and then deploy objects either manually, or via the [deploy/stage.sh](../deploy/stage.sh) script.  (you will need to be logged in with an appropriate cluster user with cluster-admin access)

### Add an opaque secret using the parameter-secret.json.sample as a template

Currently a manual secret creation is still required until the process is refactored to use vaulted secrets.

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

Ensure the service account has been created on the NFS host with SSH Key access and passwordless sudo for ansible automation.

## Redeploy openshift-ansible-service-broker

Once all objects have been created appropriately, manually trigger a redeploy of the broker.

``` bash
oc rollout latest dc/asb -n openshift-ansible-service-broker
oc rollout status dc/asb -n openshift-ansible-service-broker
```

## Verify apb

(note: svcat may take up to 10 minutes to show up due to catalog refresh timer):

``` bash
oc get images -n openshift | grep backup-pvc-apb
svcat sync broker ansible-service-broker
svcat get plans | grep backup-pvc
```

## Test

Test creating serviceInstance through the GUI and you should only see project and size as parameters.
