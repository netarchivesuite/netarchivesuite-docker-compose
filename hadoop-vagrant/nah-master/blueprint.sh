#!/usr/bin/env bash

SCRIPT_DIR=$(dirname "$(readlink -f -- ${BASH_SOURCE[0]})")

pushd $SCRIPT_DIR > /dev/null
source ../utils/machines.sh

jq --version || (sudo yum install -y epel-release; sudo yum install -y jq)


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



echo "Query Ambari for the hadoop hosts, to ensure that all the datanodes have been found"
hosts=$(get "hosts" |grep host_name| sed -n 's/.*"host_name" : "\([^\"]*\)".*/\1/p')
echo "Hadoop hosts identified as $hosts"
for datanode in $DATANODES; do
	if ! (echo "$hosts" | grep -q $datanode); then
		echo "Not all requrired hosts ($DATANODES) found in $hosts, manual intervention required";
		exit 1
	fi
done




waitForComponentStatus HDFS STARTED

waitForComponentStatus YARN STARTED

echo "Sleep for 30 seconds to give Ambari time to start the remaining services"
sleep 30


popd > /dev/null
