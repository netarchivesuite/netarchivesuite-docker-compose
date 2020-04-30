#!/usr/bin/env bash
set -e
cd /vagrant/nah-master
source ../common.sh
source ../machines.sh


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
