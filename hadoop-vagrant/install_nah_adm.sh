#!/usr/bin/env bash

SCRIPT_DIR=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
pushd $SCRIPT_DIR > /dev/null
name=nah-adm

source install_common.sh

set -x

utils/DNSMasq.sh off

#Destroy beforehand, to ensure a clean slate
vagrant destroy -f $name
#Start the machine. This causes it to do a yum update, which require a reload
vagrant up $name

#So reload the machine
vagrant reload $name
sleep 10
vagrant snapshot save $name $name-1-clean


doOrRestore $name "$name-2-ipa_server" "sudo /vagrant/$name/Install_IPA.sh"

#Setup the shared homes
doOrRestore $name "$name-3-home_server" "sudo /vagrant/$name/home_server.sh"

#Setup the users
doOrRestore $name "$name-4-users_created" "sudo /vagrant/$name/setup_users.sh"

#Use the new freeIPA as a dns server
utils/DNSMasq.sh on


popd > /dev/null

