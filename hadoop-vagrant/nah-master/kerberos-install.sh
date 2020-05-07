#!/usr/bin/env bash

SCRIPT_DIR=/vagrant/nah-master
cd $SCRIPT_DIR
source ../common.sh
source ../machines.sh





kinit_admin
set -x

#TODO how to get ambari to start kerberos creation programmatically
#https://github.com/apache/ambari/blob/branch-2.5/ambari-server/docs/security/kerberos/enabling_kerberos.md

source <(bash $SCRIPT_DIR/kerberos-create.sh $IPA_SERVER $SCRIPT_DIR/kerberos.csv hosts)

source <(bash $SCRIPT_DIR/kerberos-create.sh $IPA_SERVER $SCRIPT_DIR/kerberos.csv services)



sudo -u vagrant -i <<-EOF

	source /vagrant/machines.sh

	mkdir -p /vagrant/keytabs
	cd /vagrant/keytabs

	kinit_admin

	source <(bash $SCRIPT_DIR/kerberos-create.sh $IPA_SERVER $SCRIPT_DIR/kerberos.csv keytabs)


	source <(bash $SCRIPT_DIR/kerberos-create.sh $IPA_SERVER $SCRIPT_DIR/kerberos.csv distribute)

EOF
