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
    --enable-fips-image

if [ "$OS" == "win" ] ; then
    OS_PARAMS="
        --name win1
        --os-type=windows
        --os-sku=Windows2022"
elif [ "$OS" == "lin" ] ; then
    OS_PARAMS="
        --name lin1
        --os-type=Linux
        --os-sku=Ubuntu"
else
    echo "Unknown OS '${OS}'!"
    exit
fi

az aks nodepool add \
    $SUBSCRIPTION_PARAM \
    --resource-group $RESOURCE_GROUP \
    --cluster-name $CLUSTER_NAME \
    --max-pods=$PODS_PER_NODE \
    --node-osdisk-type=Ephemeral \
    --node-vm-size=Standard_D8d_v5 \
    --mode User \
    --min-count 1 \
    --max-count 30 \
    --enable-cluster-autoscaler \
    --zones 1 2 3 \
    --enable-encryption-at-host \
    --enable-fips-image \
    $OS_PARAMS

az aks get-credentials \
    $SUBSCRIPTION_PARAM \
    --resource-group $RESOURCE_GROUP \
    --name $CLUSTER_NAME

az aks show \
    $SUBSCRIPTION_PARAM \
    --name $CLUSTER_NAME \
    --resource-group $RESOURCE_GROUP
