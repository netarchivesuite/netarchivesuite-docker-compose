#!/usr/bin/env bash

SCRIPT_DIR=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
pushd $SCRIPT_DIR > /dev/null
name=nah-master
set -x

#Destroy beforehand, to ensure a clean slate
vagrant destroy -f $name
#Start the machine. This causes it to do a yum update, which require a reload
vagrant up $name
#So reload the machine
vagrant reload $name
#Sync the /vagrant folder
vagrant sshfs $name

vagrant ssh --command "sudo /vagrant/clients/ipaclient.sh" $name
vagrant ssh --command "sudo /vagrant/clients/ambari_client.sh" $name

vagrant ssh --command "sudo /vagrant/$name/postgres.sh" $name
vagrant ssh --command "sudo /vagrant/$name/ambari.sh" $name


#Restart the ambari agents, to ensure that they will connect now that ambari is running
nodes="nah-data-001
nah-data-002
nah-data-003
$name"
echo "$nodes" | xargs -r -i -n 1 -P 4 vagrant ssh --command 'sudo systemctl restart ambari-agent' {};

vagrant ssh --command "sudo /vagrant/$name/ssh_access.sh" $name


vagrant ssh --command "sudo /vagrant/$name/blueprint.sh" $name
vagrant ssh --command "sudo /vagrant/$name/kerberos-enable.sh" $name

echo "Restarting the hadoop cluster. It seems to be the best way to ensure that EVERYTHING have been stopped"
vagrant reload nah-master nah-data-001 nah-data-002 nah-data-003

vagrant ssh --command "sudo /vagrant/$name/clusterStart.sh" $name

popd > /dev/null
