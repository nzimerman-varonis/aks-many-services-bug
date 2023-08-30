#!/bin/bash

set -ex

source config.sh

# Generate random password for Windows nodes, and put it in a file.
if [ "$WINDOWS_ADMIN_PASSWORD" == "" ] ; then

    PASSWORD_LENGTH=20

    # Generate password that matches Azure password complexity rules -
    # must have at least one uppercase, one lowercase and one digit.
    while true ; do
        WINDOWS_ADMIN_PASSWORD=$(cat /dev/urandom | tr --delete --complement A-Za-z0-9 | head -c $PASSWORD_LENGTH)

        PASSWORD_UPPERCASE_CHARS=$(echo $WINDOWS_ADMIN_PASSWORD | tr --delete --complement A-Z)
        PASSWORD_LOWERCASE_CHARS=$(echo $WINDOWS_ADMIN_PASSWORD | tr --delete --complement a-z)
        PASSWORD_DIGITS_CHARS=$(echo $WINDOWS_ADMIN_PASSWORD    | tr --delete --complement 0-9)

        if [[ ( ${#PASSWORD_UPPERCASE_CHARS} != 0 ) &&
              ( ${#PASSWORD_LOWERCASE_CHARS} != 0 ) &&
              ( ${#PASSWORD_DIGITS_CHARS}    != 0 ) ]] ; then
            break
        fi
    done

    echo $WINDOWS_ADMIN_PASSWORD > windows-password.txt
fi

# Configure overlay network plugin mode if requested.
if [ "$NETWORK_PLUGIN_MODE" == "overlay" ] ; then
    NETWORK_PLUGIN_MODE_PARAMS="
        --network-plugin-mode overlay
        --pod-cidr 192.168.0.0/16"
elif [ "$NETWORK_PLUGIN_MODE" == "" ] ; then
    NETWORK_PLUGIN_MODE_PARAMS=""
else
    echo "Unknown network plugin mode '${NETWORK_PLUGIN_MODE}'!"
    exit
fi

az aks create \
    $SUBSCRIPTION_PARAM \
    --name $CLUSTER_NAME \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION \
    --network-plugin azure \
    --network-policy azure \
    --generate-ssh-keys \
    --windows-admin-username azureuser \
    --windows-admin-password $WINDOWS_ADMIN_PASSWORD \
    --zones 1 2 3 \
    --nodepool-name system \
    --enable-encryption-at-host \
    --enable-fips-image \
    --tier $AKS_TIER \
    $NETWORK_PLUGIN_MODE_PARAMS

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
