#!/bin/bash

set -ex

source config.sh

if [ "$OS" == "win" ] ; then
    OS_PARAMS="
        --name win1"
elif [ "$OS" == "lin" ] ; then
    OS_PARAMS="
        --name lin1"
else
    echo "Unknown OS '${OS}'!"
    exit
fi

az aks nodepool delete \
    $SUBSCRIPTION_PARAM \
    --cluster-name $CLUSTER_NAME \
    --resource-group $RESOURCE_GROUP \
    $OS_PARAMS
