#!/usr/bin/env bash

SCRIPT_DIR=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
pushd $SCRIPT_DIR > /dev/null
source ../utils/machines.sh


set -e


#Install the database
yum install -y postgresql-server

#Setup the database
rm -rf /var/lib/pgsql/data
postgresql-setup initdb
systemctl enable postgresql

append /var/lib/pgsql/data/postgresql.conf "listen_addresses='*'"

#7.3  Ambari Server
#7.3.1  Ambari Database

#Create ambari database access
append /var/lib/pgsql/data/pg_hba.conf "host     ambari          ambari          $(hostname -f)               md5"

systemctl restart postgresql

createDB ambari ambari

popd > /dev/null
