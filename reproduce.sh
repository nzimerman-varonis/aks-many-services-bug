#!/bin/bash

set -exu

source config.sh

apply_single_yaml_template()
{
  local YAML_TEMPLATE=$1

  cat $YAML_TEMPLATE | 
    sed s/{{UUID}}/$(uuidgen | sed s/-//g | cut -c1-10)/ |
    $KUBECTL apply -f -
}

apply_yaml_templates()
{
  local TOTAL=$1
  local YAML_TEMPLATE=$2

  local BATCH_SIZE=25

  local CHILDREN_PIDS=()
  local CHILDREN_IN_BATCH=0

  for (( T = 0; T < $TOTAL; T++ ))
  do
    ( apply_single_yaml_template $YAML_TEMPLATE ) &
    local CHILD_PID=$!
    CHILDREN_PIDS+=($CHILD_PID)

    CHILDREN_IN_BATCH=$((CHILDREN_IN_BATCH+1))

    if (( $CHILDREN_IN_BATCH > $BATCH_SIZE ))
    then
      wait ${CHILDREN_PIDS[@]}

      CHILDREN_IN_BATCH=0
      CHILDREN_PIDS=()
    fi
  done

  wait ${CHILDREN_PIDS[@]}
}


### Create daemonset for UDP range patch -

$KUBECTL apply -f increase-udp-port-range.yaml
$KUBECTL rollout status -w -f increase-udp-port-range.yaml


### Create deployments and services

YAML_TEMPLATE="${APP_NAME}-${OS}-deployment-and-service-template.yaml"
apply_yaml_templates 3000 $YAML_TEMPLATE
