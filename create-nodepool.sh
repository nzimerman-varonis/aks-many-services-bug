#!/bin/bash

set -ex

source config.sh

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
    --max-count 40 \
    --enable-cluster-autoscaler \
    --zones 1 2 3 \
    --enable-encryption-at-host \
    --enable-fips-image \
    $OS_PARAMS
