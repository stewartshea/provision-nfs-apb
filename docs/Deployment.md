# Deployment Steps

## Build/Push APB Image to openshift project

Local package requirements:

- oc client
- apb cli (https://docs.okd.io/3.10/apb_devel/cli_tooling.html)
- local docker

`oc login` (as user with cluster-admin)

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
```

If the push shows an error at the bootstrap step, run the following to bootstrap the broker and sync the catalog (instead of waiting for the timed bootstrap and sync)

``` bash
    Get name of route:
    oc get route -n openshift-ansible-service-broker
    curl -H "Authorization: Bearer $(oc whoami -t)" -k -X POST \
    https://<name_of_route>/ansible-service-broker/v2/bootstrap

    wait for bootstrap to complete, and then sync(relist) the catalog
    svcat sync broker ansible-service-broker
```

# Verify apb

(note: svcat may take up to 10 minutes to show up due to catalog refresh timer):

``` bash
oc get images -n openshift | grep backup-pvc-apb
svcat sync broker ansible-service-broker
svcat get plans | grep backup-pvc
```

## Update openshift-ansible-service-broker

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

Add "nfs-file" storageclass
`(need to refactor as secret variable instead of hard-coded name)`

``` yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: nfs-file
provisioner: no-provisioning
reclaimPolicy: Delete
volumeBindingMode: Immediate
```

Redeploy openshift-ansible-service-broker to use new cm/broker-config

Test creating serviceInstance. (Should only see project and size as parameters)
