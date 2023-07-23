#!/bin/bash

set -ex

source config.sh

az aks delete \
    $SUBSCRIPTION_PARAM \
    --name $CLUSTER_NAME \
    --resource-group $RESOURCE_GROUP
