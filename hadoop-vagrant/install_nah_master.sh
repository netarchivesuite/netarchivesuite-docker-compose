#!/usr/bin/env bash

SCRIPT_DIR=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
pushd $SCRIPT_DIR > /dev/null
source install_common.sh


name=nah-master


set -x
set -e


if ( vagrant status "$name" | grep "nah-master\s*not created"); then
    #Start the machine. This causes it to do a yum update, which require a reload
    vagrant up "$name"
    #So reload the machine
    vagrant reload "$name"
    vagrant snapshot save "$name" "$name-1-clean"
else
    vagrant snapshot restore --no-start "$name" "$name-1-clean"
fi



doOrRestore "$name" "$name-2-clients" "sudo /vagrant/clients/ipaclient.sh" "sudo /vagrant/clients/ambari_client.sh"


doOrRestore "$name" "$name-3-ambari_server" "sudo /vagrant/$name/postgres.sh" "sudo /vagrant/$name/ambari.sh" "sudo /vagrant/$name/ssh_access.sh"

vagrant up "$name"

#Restart the ambari agents, to ensure that they will connect now that ambari is running
nodes="$DATANODES
$name"
echo "$nodes" | xargs -r -i -n 1 -P 4 vagrant ssh --command 'sudo systemctl restart ambari-agent' {};


echo "Installing hadoop cluster from blueprint"
doOrRestore $name $name-4-unsecured_cluster "sudo /vagrant/$name/blueprint.sh"
echo "Hadoop cluster installed"
#
#echo "Setting up kerberos"
#doOrRestore $name $name-5-kerberos_cluster "sudo /vagrant/$name/kerberos-enable.sh"
#echo "Kerberos set up"
#

echo "Restarting the hadoop cluster. It seems to be the best way to ensure that EVERYTHING have been stopped"
vagrant reload -f nah-master $DATANODES

vagrant ssh --command "sudo /vagrant/$name/clusterStart.sh" $name


popd > /dev/null
