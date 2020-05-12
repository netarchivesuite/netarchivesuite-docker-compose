#!/usr/bin/env bash

SCRIPT_DIR=$(dirname $(readlink -f ${BASH_SOURCE[0]}))


#Destroy beforehand, to ensure a clean slate
vagrant destroy -f nah-master
#Start the machine. This causes it to do a yum update, which require a reload
vagrant up nah-master
#So reload the machine
vagrant reload nah-master
#Sync the /vagrant folder
vagrant rsync nah-master


vagrant ssh --command "sudo /vagrant/clients/ipaclient.sh" nah-master
vagrant ssh --command "sudo /vagrant/clients/ambari_client.sh" nah-master
vagrant ssh --command "sudo /vagrant/nah-master/postgres.sh" nah-master
vagrant ssh --command "sudo /vagrant/nah-master/ambari.sh" nah-master
vagrant ssh --command "sudo /vagrant/nah-master/blueprint.sh" nah-master
vagrant ssh --command "sudo /vagrant/nah-master/ssh_access.sh" nah-master
vagrant ssh --command "sudo /vagrant/nah-master/kerberos-enable.sh" nah-master


#Sync the /vagrant folder with passwords and the like
vagrant rsync nah-master

