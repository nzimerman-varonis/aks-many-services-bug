#!/bin/bash

set -ex

NODE_IP=$1

if [ "$NODE_IP" == "" ] ; then
    echo "Node IP must be specified!"
    exit
fi

# Get one of the Linux nodes
LINUX_NODE=$(kubectl get nodes | grep system | head -1 | gawk '{ print $1 }')

# Start a debug pod on the Linux node, without attaching to it
DEBUG_POD=$(kubectl debug node/$LINUX_NODE -ti --attach=false --image=alpine | gawk '{ print $4 }')

# Wait for debug pod to become ready
kubectl wait pod $DEBUG_POD --for condition=Ready --timeout=10s

# Install openssh and sshpass in the debug pod
kubectl exec -ti $DEBUG_POD -- /bin/sh -c "apk update && apk add openssh sshpass"

# SSH into a Windows node, using password from file
kubectl exec -ti $DEBUG_POD -- sshpass -p $(cat windows-password.txt) ssh azureuser@${NODE_IP} -o StrictHostKeyChecking=no

# Delete the debug pod
kubectl delete pod $DEBUG_POD --wait=false
