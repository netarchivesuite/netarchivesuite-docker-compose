#!/usr/bin/env bash

SCRIPT_DIR=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
pushd $SCRIPT_DIR > /dev/null

set -x

#Start the machine. This causes it to do a yum update, which require a reload
datanodes="nah-data-001
nah-data-002
nah-data-003"

echo "$datanodes" | xargs -r -i -n 1 -P 3 bash -c "
sleep \$[ ( \$RANDOM % 10 )  + 1 ]s
node={};
vagrant destroy -f \$node;
vagrant up \$node;
vagrant sshfs \$node;
vagrant ssh --command 'sudo /vagrant/clients/ipaclient.sh' \$node;
vagrant ssh --command 'sudo /vagrant/clients/ambari_client.sh' \$node;
"

popd > /dev/null
