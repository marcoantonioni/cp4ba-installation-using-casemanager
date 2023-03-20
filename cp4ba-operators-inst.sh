#!/bin/bash

export CP4BA_AUTO_DEPLOYMENT_TYPE="starter"
export CP4BA_AUTO_PLATFORM="ROKS"
export CP4BA_AUTO_ALL_NAMESPACES="No"
export CP4BA_AUTO_STORAGE_CLASS_FAST_ROKS="managed-nfs-storage"

export CP4BA_AUTO_NAMESPACE="cp4ba"

# export CP4BA_AUTO_CLUSTER_USER="IAM#...your-id..."

if [ "${CP4BA_AUTO_ENTITLEMENT_KEY}" == "" ]; then
  echo "ERROR: env var CP4BA_AUTO_ENTITLEMENT_KEY not set !"
  exit
fi


if [ "${CP4BA_AUTO_CLUSTER_USER}" == "" ]; then
  echo "ERROR: env var CP4BA_AUTO_CLUSTER_USER not set !"
  exit
fi

oc new-project ${CP4BA_AUTO_NAMESPACE}

cat << EOF | oc create -n ${CP4BA_AUTO_NAMESPACE} -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ibm-cp4ba-anyuid
imagePullSecrets:
- name: 'ibm-entitlement-key'
EOF

oc adm policy add-scc-to-user anyuid -z ibm-cp4ba-anyuid -n ${CP4BA_AUTO_NAMESPACE}

./cp4a-clusteradmin-setup.sh

while true
do
  echo ""
  echo "=============================================="
  oc get ClusterServiceVersion -n ${CP4BA_AUTO_NAMESPACE} 
  NOTREADY=$(oc get ClusterServiceVersion -n ${CP4BA_AUTO_NAMESPACE} | grep -E "Installing|InstallReady|Failed|Pending|UpgradePending" | wc -l)
  if [ "$NOTREADY" == "0" ]; then
    echo "OK operators are all ready"
    break
  else
    echo ""
    echo "Waiting for "$NOTREADY" operator..."
    sleep 10
  fi
done

echo "Wait for pods readiness before CR deployment..."
sleep 300

echo "Run: ./cp4a-deployment.sh"
echo "Or Run: oc apply -f ./generated-cr/ibm_cp4a_cr_final.yaml"
