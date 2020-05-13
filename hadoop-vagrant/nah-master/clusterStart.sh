#!/usr/bin/env bash

SCRIPT_DIR=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
pushd $SCRIPT_DIR > /dev/null
source ../utils/machines.sh

echo "Start all services"
put  "clusters/$CLUSTER_NAME/services" '{"ServiceInfo": {"state": "STARTED"}}'

popd > /dev/null
