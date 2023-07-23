#!/bin/bash

set -ex

source config.sh

az feature register \
    $SUBSCRIPTION_PARAM \
    --namespace "Microsoft.ContainerService" \
    --name "AzureOverlayPreview"

az feature show \
    $SUBSCRIPTION_PARAM \
    --namespace "Microsoft.ContainerService" \
    --name "AzureOverlayPreview"

az group create \
    $SUBSCRIPTION_PARAM \
    --name $RESOURCE_GROUP \
    --location $LOCATION
