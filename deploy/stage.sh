#!/bin/bash
#OC="oc --as=someServiceAcct"
OC=oc

APB_IMAGE_NAME=backup-pvc-apb

echo "Image Search:"
$OC -n openshift get images | grep ${APB_IMAGE_NAME}
rc=(${PIPESTATUS[@]})

if [ ${rc[0]} -ne 0 ] ; then
  echo "Error with oc command, please ensure you are logged into your cluster with cluster-admin privileges."
  exit 1
fi

if [ ${rc[1]} -ne 0 ] ; then
  echo "WARNING: Missing ${APB_IMAGE_NAME} apb image, please push the apb image using apb cli"
fi

echo ""
echo "Note:"
echo "  APB Secret upload is not automated yet.  Please ensure the secret name matches the parameter"
echo ""

echo "Create or replace service Account"
cat templates/parameters.yaml templates/pv-provisioner-svc-acct.yaml | ${OC} process -f - | ${OC} apply -f -

echo ""
echo "Create or replace storageClass"
cat templates/parameters.yaml templates/nfs-backup-storageClass.yaml | ${OC} process -f - | ${OC} apply -f -

echo ""
echo "Create or replace broker-config"
cat templates/parameters.yaml templates/broker-config.yaml | ${OC} process -f - | ${OC} apply -f -

echo ""
echo "Creating BuildConfig in openshift project"
cat templates/backup-pvc-apb-bc.yaml | ${OC} process -f - | ${OC} apply -f -

echo "Trigger build with the following when ready:"
echo "${OC} start-build --from-build=backup-pvc-apb"

echo ""
echo "Once build completes and broker has been configured, run the following to bootstrap the broker:"
echo "curl -H \"Authorization: Bearer \$(oc whoami -t)\" -k -X POST \\"
echo " https://\$(oc get route -n openshift-ansible-service-broker | grep asb | awk -f '{print $2}')/ansible-service-broker/v2/bootstrap"

echo ""
echo "Run the following to sync the Service Catalog:"
echo "svcat sync ansible-service-broker"
