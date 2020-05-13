#!/usr/bin/env bash

SCRIPT_DIR=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
pushd $SCRIPT_DIR > /dev/null
name=nah-adm

set -x

utils/DNSMasq.sh off

#Destroy beforehand, to ensure a clean slate
vagrant destroy -f $name
#Start the machine. This causes it to do a yum update, which require a reload
vagrant up $name
#So reload the machine
vagrant reload $name
#Sync the /vagrant folder
vagrant sshfs $name

#Install freeIPA
vagrant ssh --command "sudo /vagrant/$name/Install_IPA.sh" $name

#Setup the shared homes
vagrant ssh --command "sudo /vagrant/$name/home_server.sh" $name

#Setup the users
vagrant ssh --command "sudo /vagrant/$name/setup_users.sh" $name

#Sync the /vagrant folder with passwords and the like

#Use the new freeIPA as a dns server
utils/DNSMasq.sh on


popd > /dev/null

