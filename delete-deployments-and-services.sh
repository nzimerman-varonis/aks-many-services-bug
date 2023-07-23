#!/bin/bash

set -ex

source config.sh


wait_for_pods_amount()
{
  local PODS=$1

  while (( $($KUBECTL get pods --no-headers -l group=${APP_NAME} | wc -l) != $(( PODS )) ))
  do
    echo Waiting...
    sleep 5
  done
}


XARGS_BATCH_SIZE=50

$KUBECTL get deployment -l group=${APP_NAME} -o custom-columns=:.metadata.name | xargs -n 1 -P $XARGS_BATCH_SIZE -- $KUBECTL delete deployment
$KUBECTL get service    -l group=${APP_NAME} -o custom-columns=:.metadata.name | xargs -n 1 -P $XARGS_BATCH_SIZE -- $KUBECTL delete service

wait_for_pods_amount 0
