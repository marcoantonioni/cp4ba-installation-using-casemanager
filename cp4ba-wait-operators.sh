#!/bin/bash

if [ "${CP4BA_AUTO_ENTITLEMENT_KEY}" == "" ]; then
  echo "ERROR: env var CP4BA_AUTO_ENTITLEMENT_KEY not set !"
  exit
fi

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