#!/bin/bash

set -ex

source config.sh

# Generate random password for Windows nodes, and put it in a file.
if [ "$WINDOWS_ADMIN_PASSWORD" == "" ] ; then
    WINDOWS_ADMIN_PASSWORD=$(cat /dev/urandom | tr --delete --complement A-Za-z0-9 | head -c 20)
    echo $WINDOWS_ADMIN_PASSWORD > windows-password.txt
fi

az aks create \
    $SUBSCRIPTION_PARAM \
    --name $CLUSTER_NAME \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION \
    --network-plugin azure \
    --network-plugin-mode overlay \
    --network-policy azure \
    --pod-cidr 192.168.0.0/16 \
    --generate-ssh-keys \
    --windows-admin-username azureuser \
    --windows-admin-password $WINDOWS_ADMIN_PASSWORD \
    --zones 1 2 3 \
    --nodepool-name system \
    --enable-encryption-at-host \
    --enable-fips-image \
    --tier $AKS_TIER

./create-nodepool.sh

az aks get-credentials \
    $SUBSCRIPTION_PARAM \
    --resource-group $RESOURCE_GROUP \
    --name $CLUSTER_NAME

az aks show \
    $SUBSCRIPTION_PARAM \
    --name $CLUSTER_NAME \
    --resource-group $RESOURCE_GROUP

if [ "$INSECURE_SKIP_TLS_VERIFY" == "true" ] ; then
    # Disable kubectl certificate checks for this cluster
    $KUBECTL config set-cluster $CLUSTER_NAME --insecure-skip-tls-verify=true
fi
