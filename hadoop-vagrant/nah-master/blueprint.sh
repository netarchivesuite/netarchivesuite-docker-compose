#!/usr/bin/env bash

set -e
cd /vagrant/nah-master
source ../common.sh
source ../machines.sh



function get(){
    local path="$1"
    curl -s -H "X-Requested-By: ambari" -X GET -u "admin:$adminPass" "http://$MASTER_NAME:8080/api/v1/$path"
}

function delete(){
    local path="$1"
    curl -q -s -H "X-Requested-By: ambari" -X DELETE -u "admin:$adminPass" "http://$MASTER_NAME:8080/api/v1/$path"
}


function post(){
    local path="$1"
    local body="$2"
    curl -s -H "X-Requested-By: ambari" -X POST -u "admin:$adminPass" "http://$MASTER_NAME:8080/api/v1/$path" -d $body
}


adminPass=$(get_password admin)

#set -e makes the execution stop if anything fails
set -e
#Step 2: Register Blueprint with Ambari
delete "blueprints/$CLUSTER_NAME" || true

sleep 5

post "blueprints/$CLUSTER_NAME" @/vagrant/nah-master/blueprint.json

sleep 10
get "blueprints/$CLUSTER_NAME"

sleep 5

#Step 3: Create Cluster Creation Template
delete "clusters/$CLUSTER_NAME" || true

sleep 10

post "clusters/$CLUSTER_NAME" @/vagrant/nah-master/cluster.json
sleep 30
set +e