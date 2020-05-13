#!/usr/bin/env bash

SCRIPT_DIR=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
pushd $SCRIPT_DIR > /dev/null


#Destroy beforehand, to ensure a clean slate
vagrant destroy -f nah-master
#Start the machine. This causes it to do a yum update, which require a reload
vagrant up nah-master
#So reload the machine
vagrant reload nah-master
#Sync the /vagrant folder
vagrant sshfs nah-master

vagrant ssh --command "sudo /vagrant/clients/ipaclient.sh" nah-master
vagrant ssh --command "sudo /vagrant/clients/ambari_client.sh" nah-master
vagrant ssh --command "sudo /vagrant/nah-master/postgres.sh" nah-master
vagrant ssh --command "sudo /vagrant/nah-master/ambari.sh" nah-master

#Restart the ambari agents, to ensure that they will connect now that ambari is running
nodes="nah-data-001
nah-data-002
nah-data-003
nah-master"
echo "$nodes" | xargs -r -i -n 1 -P 4 vagrant ssh --command 'sudo systemctl restart ambari-agent' {};


vagrant ssh --command "sudo /vagrant/nah-master/blueprint.sh" nah-master
vagrant ssh --command "sudo /vagrant/nah-master/ssh_access.sh" nah-master
vagrant ssh --command "sudo /vagrant/nah-master/kerberos-enable.sh" nah-master

popd > /dev/null
