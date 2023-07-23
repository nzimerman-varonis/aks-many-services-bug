#!/bin/bash

set -ex

source config.sh

az group delete \
    $SUBSCRIPTION_PARAM \
    --name $RESOURCE_GROUP
