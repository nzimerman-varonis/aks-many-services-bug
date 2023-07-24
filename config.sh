#!/bin/bash

set -ex


# If not set, uses the currently active subscription.
SUBSCRIPTION=""

RESOURCE_GROUP="aks-many-services-bug-$USER-rg"
CLUSTER_NAME="aks-many-services-bug-$USER"
LOCATION="eastus"

PODS_PER_NODE=135

KUBECTL="kubectl"


### Don't change below this line ###

APP_NAME="wait-forever"

if [ "$SUBSCRIPTION" != "" ] ; then
    SUBSCRIPTION_PARAM="--subscription $SUBSCRIPTION"
else
    SUBSCRIPTION_PARAM=""
fi
