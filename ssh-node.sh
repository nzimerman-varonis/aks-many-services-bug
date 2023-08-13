#!/bin/bash

set -ex

source config.sh

NODE_NAME=$1

if [ "$NODE_NAME" == "" ] ; then
    echo "Node name must be specified!"
    exit
fi

# Get one of the Linux nodes
LINUX_NODE=$($KUBECTL get nodes | grep system | head -1 | gawk '{ print $1 }')

# Start a debug pod on the Linux node, without attaching to it
DEBUG_POD=$($KUBECTL debug node/$LINUX_NODE -ti --attach=false --image=alpine | gawk '{ print $4 }')

# Wait for debug pod to become ready
$KUBECTL wait pod $DEBUG_POD --for condition=Ready --timeout=10s

# Install openssh and sshpass in the debug pod
$KUBECTL exec -ti $DEBUG_POD -- /bin/sh -c "apk update && apk add openssh sshpass"

# Get target node IP from node name
NODE_IP=$($KUBECTL get node $NODE_NAME -o jsonpath="{.status.addresses[0].address}")

# SSH into a Windows node, using password from file
$KUBECTL exec -ti $DEBUG_POD -- sshpass -p $(cat windows-password.txt) ssh azureuser@${NODE_IP} -o StrictHostKeyChecking=no -o ServerAliveInterval=15 -o ServerAliveCountMax=3

# Delete the debug pod
$KUBECTL delete pod $DEBUG_POD --wait=false
