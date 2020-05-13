#!/usr/bin/env bash

SCRIPT_DIR=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
pushd $SCRIPT_DIR > /dev/null
source ../utils/machines.sh

set -e



function get(){
    local path="$1"
    curl -s -H "X-Requested-By: ambari" -X GET -u "admin:$(get_password admin)" "http://$MASTER_NAME:8080/api/v1/$path"
}

function delete(){
    local path="$1"
    curl -s -H "X-Requested-By: ambari" -X DELETE -u "admin:$(get_password admin)" "http://$MASTER_NAME:8080/api/v1/$path"
}


function post(){
    local path="$1"
    local body="$2"
    curl -s -H "X-Requested-By: ambari" -X POST -u "admin:$(get_password admin)" "http://$MASTER_NAME:8080/api/v1/$path" -d $body
}


#set -e makes the execution stop if anything fails
set -e
echo "Step 2: Register Blueprint with Ambari"
delete "blueprints/$CLUSTER_NAME" > /dev/null || true

sleep 5

post "blueprints/$CLUSTER_NAME" @/vagrant/nah-master/blueprint.json

sleep 10
get "blueprints/$CLUSTER_NAME"

sleep 5

echo "Step 3: Create Cluster Creation Template"
delete "clusters/$CLUSTER_NAME" || true

sleep 10

post "clusters/$CLUSTER_NAME" @/vagrant/nah-master/cluster.json
sleep 30
set +e

jq --version || (sudo yum install -y epel-release; sudo yum install -y jq)

echo "Wait for HDFS to be started"
while : ; do
   hdfsState=$(get "clusters/$CLUSTER_NAME/services/HDFS" | jq '.ServiceInfo.state' -r)
   [[ "$hdfsState" = "Started" ]] || break
done

echo "Wait for Ambari metrics to be started. This seems to be the last service started, so when it is done, the startup is done"
while : ; do
   metricsState=$(get "clusters/$CLUSTER_NAME/services/AMBARI_METRICS" | jq '.ServiceInfo.state' -r)
   [[ "$metricsState" = "Started" ]] || break
done


popd > /dev/null
