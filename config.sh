#!/bin/bash

set -ex


# If not set, uses the currently active subscription.
SUBSCRIPTION=""

RESOURCE_GROUP="aks-many-services-bug-$USER-rg"
CLUSTER_NAME="aks-many-services-bug-$USER"
LOCATION="eastus"

AKS_TIER="free"
#AKS_TIER="standard"

# Network plugin mode can be "overlay" for Azure CNI Overlay or left empty for standard Azure CNI.
NETWORK_PLUGIN_MODE="overlay"
#NETWORK_PLUGIN_MODE=""

PODS_PER_NODE=135

# If left empty, a random password is created.
WINDOWS_ADMIN_PASSWORD=""

# OS - win, lin
OS="win"

KUBECTL="kubectl"

# Configure kubectl to skip verifying TLS certificates for the cluster.
# Needed when running behind TLS inspecting proxy.
INSECURE_SKIP_TLS_VERIFY="true"


### Don't change below this line ###

APP_NAME="wait-forever"

if [ "$SUBSCRIPTION" != "" ] ; then
    SUBSCRIPTION_PARAM="--subscription $SUBSCRIPTION"
else
    SUBSCRIPTION_PARAM=""
fi
