#!/usr/bin/env bash

SCRIPT_DIR=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
pushd $SCRIPT_DIR > /dev/null


utils/DNSMasq.sh off

#Destroy beforehand, to ensure a clean slate
vagrant destroy -f nah-adm
#Start the machine. This causes it to do a yum update, which require a reload
vagrant up nah-adm
#So reload the machine
vagrant reload nah-adm
#Sync the /vagrant folder
vagrant sshfs nah-adm

#Install freeIPA
vagrant ssh --command "sudo /vagrant/nah-adm/Install_IPA.sh" nah-adm

#Setup the shared homes
vagrant ssh --command "sudo /vagrant/nah-adm/home_server.sh" nah-adm

#Setup the users
vagrant ssh --command "sudo /vagrant/nah-adm/setup_users.sh" nah-adm

#Sync the /vagrant folder with passwords and the like

#Use the new freeIPA as a dns server
utils/DNSMasq.sh on


popd > /dev/null

