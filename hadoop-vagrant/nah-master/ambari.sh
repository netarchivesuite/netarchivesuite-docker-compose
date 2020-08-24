#!/usr/bin/env bash

SCRIPT_DIR=$(dirname "$(readlink -f -- ${BASH_SOURCE[0]})")
pushd $SCRIPT_DIR > /dev/null
source ../utils/machines.sh

set -e


#Install java 8
yum install -y java-1.8.0-openjdk-devel

#Ambari Repo
yum install -y wget
wget -nv "$ambari_repo" -O /etc/yum.repos.d/ambari.repo
# Install Ambari Server
yum install -y ambari-server



# Setup Ambari Server
AMBARI_DATABASE_HOST=$(hostname -f)
AMBARI_DATABASE_NAME=ambari
AMBARI_DATABASE_USER=ambari
AMBARI_DATABASE_PASS=$(get_password postgres_ambari)
AMBARI_DATABASE_PORT=5432
AMBARI_SYSTEM_USER=ambari-server

echo -e "y\n
y\n
${AMBARI_SYSTEM_USER}\n
y\n
y\n" | \
ambari-server setup \
    --java-home=/usr/lib/jvm/java-1.8.0 \
    --enable-lzo-under-gpl-license \
    --database=postgres \
    --databasehost=${AMBARI_DATABASE_HOST} \
    --databaseport=${AMBARI_DATABASE_PORT} \
    --databasename=${AMBARI_DATABASE_NAME} \
    --postgresschema=ambari \
    --databaseusername=${AMBARI_DATABASE_USER} \
    --databasepassword=${AMBARI_DATABASE_PASS}

postgresJar=$(find /usr/lib/ambari-server/ -name postgresql-*.jar | head -n 1)
ambari-server setup \
    --jdbc-db=postgres \
    --jdbc-driver=${postgresJar}

#Create the schema
set +e
PGPASSWORD="${AMBARI_DATABASE_PASS}" psql \
    --host=${AMBARI_DATABASE_HOST} \
    --port=${AMBARI_DATABASE_PORT} \
    --username=${AMBARI_DATABASE_USER} \
    ambari \
    -c \
    "DROP SCHEMA IF EXISTS ${AMBARI_DATABASE_NAME} CASCADE;\
    CREATE SCHEMA ${AMBARI_DATABASE_NAME} AUTHORIZATION $AMBARI_DATABASE_USER; \
    ALTER SCHEMA ${AMBARI_DATABASE_NAME} OWNER TO $AMBARI_DATABASE_USER; \
    ALTER ROLE $AMBARI_DATABASE_USER SET search_path to '${AMBARI_DATABASE_NAME}', 'public';"

#Create the tables
PGPASSWORD="${AMBARI_DATABASE_PASS}" psql \
    --host=${AMBARI_DATABASE_HOST} \
    --port=${AMBARI_DATABASE_PORT} \
    --username=${AMBARI_DATABASE_USER} ambari \
    --file=/var/lib/ambari-server/resources/Ambari-DDL-Postgres-CREATE.sql

set -e
#We need these for inescapable ambari services
get_password grafana > /dev/null
get_password smartsense > /dev/null

#7.3.2  Setup ambari
sudo systemctl enable ambari-server
sudo systemctl start ambari-server

# Setup LDAP sync
append /etc/ambari-server/conf/ambari.properties "ldap.sync.username.collision.behavior=convert"
append /etc/ambari-server/conf/ambari.properties "client.security=ldap"
append /etc/ambari-server/conf/ambari.properties "ambari.ldap.isConfigured=true"
append /etc/ambari-server/conf/ambari.properties "api.authenticate=true"
append /etc/ambari-server/conf/ambari.properties "authentication.ldap.baseDn=cn=accounts,$LDAP_DOMAIN"
append /etc/ambari-server/conf/ambari.properties "authentication.ldap.bindAnonymously=false"
append /etc/ambari-server/conf/ambari.properties "authentication.ldap.dnAttribute=dn"
append /etc/ambari-server/conf/ambari.properties "authentication.ldap.groupMembershipAttr=member"
append /etc/ambari-server/conf/ambari.properties "authentication.ldap.groupNamingAttr=cn"
append /etc/ambari-server/conf/ambari.properties "authentication.ldap.groupObjectClass=posixGroup"
append /etc/ambari-server/conf/ambari.properties "authentication.ldap.managerDn=uid=ldapbind,cn=users,cn=accounts,$LDAP_DOMAIN"
append /etc/ambari-server/conf/ambari.properties "authentication.ldap.managerPassword=/etc/ambari-server/conf/ldap-password.dat"
append /etc/ambari-server/conf/ambari.properties "authentication.ldap.primaryUrl=$IPA_IP1:389"
append /etc/ambari-server/conf/ambari.properties "authentication.ldap.referral=ignore"
append /etc/ambari-server/conf/ambari.properties "authentication.ldap.useSSL=false"
append /etc/ambari-server/conf/ambari.properties "authentication.ldap.userObjectClass=posixAccount"
append /etc/ambari-server/conf/ambari.properties "authentication.ldap.usernameAttribute=uid"

yum install -y perl
#get_password ldapbind
#This strips the trailing newline, which otherwise chokes ambari up
perl -0pe 's/\n\Z//' $passwordDir/ldapbind > /etc/ambari-server/conf/ldap-password.dat

systemctl restart ambari-server

#7.3.3  Ambari Sync

yum install expect -y

# set -o verbose #Print lines as they are executed
# set -o nounset #Stop script if attempting to use an unset variable
# set +o errexit #Do not stop script if any command fails

# Two steps

# First step, sync users from LDAP

# Sync only LDAP users from nahusers
rm -f /etc/ambari-server/ambari-users.csv
append /etc/ambari-server/ambari-users.csv 'admin'



echo "Sync amad and admin. At this point, admin is a normal user, so the password is admin"
expect /vagrant/nah-master/ambari-ldap-sync.exp "admin" "admin" "--users=/etc/ambari-server/ambari-users.csv"


rm -f /etc/ambari-server/ambari-groups.csv
append /etc/ambari-server/ambari-groups.csv 'nahusers,admins,subadmins,p000,p001'

echo "Now admin have become a ldap user, so his password is now the password of the ldap server"
adminPass=$(get_password admin) # The admin account is now an LDAP account

echo "Now we sync the relevant groups with all their users. And we use the new admin pass"
expect /vagrant/nah-master/ambari-ldap-sync.exp "admin" "$adminPass" '--groups=/etc/ambari-server/ambari-groups.csv' 2>&1


# Second Step, give users Admin priviledges


#Shorthand to find members of a group
function usersFromGroup(){
    group="$1"
    ipa user-find --in-groups=nahusers --in-groups="$group" | grep 'login:' | cut -d':' -f2
}
export usersFromGroup


#Shorthand to give an ambari user admin priviledges
function makeAmbariAdmin(){
    local user="$1"
    local adminUser="$2"
    local adminPass="$3"
    local ambariHost="$4"
    curl \
        -s -S \
        --user "$adminUser:$adminPass" \
        -H 'X-Requested-By:ambari' \
        -X PUT \
        -d '{"Users" : {"admin" : "true"}}' \
        "http://$ambariHost:8080/api/v1/users/${user}"
}
export -f makeAmbariAdmin

# Kinit as admin so we can use the ipa commands
kinit_admin

adminUser="admin"
adminPass=$(get_password admin)

#Find all members of the admins group, and turn them into ambari admins
usersFromGroup admins | xargs -r -I% bash -c "makeAmbariAdmin % $adminUser $adminPass $MASTER_NAME"

#Find all members of the subadmins group and turn them into ambari admins
usersFromGroup subadmins | xargs -r -I% bash -c "makeAmbariAdmin % $adminUser $adminPass $MASTER_NAME"

# Ambari must own this folder, and it does not do so by default.
chown ambari-server:ambari-server /var/run/ambari-server/ -R

popd > /dev/null
