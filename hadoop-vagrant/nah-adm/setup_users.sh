#!/usr/bin/env bash

SCRIPT_DIR=/vagrant/nah-adm

cd $SCRIPT_DIR
source ../common.sh
source ../machines.sh


echo "3.1  Groups"
echo "Create the groups"


#set -o nounset #Stop script if attempting to use an unset variable
#set -o errexit #Stop script if any command fails


kinit_admin

ipa group-add hadoop         --gid ${hadoopGroup}            --desc='Hadoop System Services'

### These groups exists to group the services,

ipa group-add systemservices --gid ${systemServiceGroup}      --desc='Standard user accounts, for non-hadoop services'

ipa group-add ambariservices --gid ${ambariServiceGroup}      --desc='Standard user accounts, for ambari services'

## These are the groups for human users

ipa group-add subadmins --gid ${subadminsGroup} --desc='For daily administration of users and hosts'

ipa group-add admins    --gid ${adminsGroup}    --desc='Account administrators group'

ipa group-add nahusers      --gid ${usersGroup}     --desc='Standard user accounts, for unprivileged users.'

ipa group-add hdfs          --gid ${hdfsGroup}      --desc='HDFS group'

##Project groups
ipa group-add p000       --gid ${p000Group} --desc='Group for project p000'
ipa group-add p001       --gid ${p001Group} --desc='Group for project p001'
#ipa group-add p002       --gid ${p002Group} --desc='Group for project p002'
#ipa group-add p003       --gid ${p003Group} --desc='Group for project p003'

echo "3.2  System Users"
echo "Remove all system users. Useful when you want to recreate the users"
ipa user-find --class SystemUser | grep login: | cut -d':' -f2 | xargs -r ipa user-del


echo "3.2.1  ldapbind, jupyterhub and rstudio"


echo "# System services"

ipa user-add ldapbind \
    --first='Bind User' \
    --homedir=/syshome/ldapbind \
    --uid=$((systemServiceGroup+1)) \
    --shell=/sbin/nologin \
    --gidnumber=$((systemServiceGroup+1)) \
    --last='LDAP' \
    --class=SystemUser
ipa group-add-member systemservices --user ldapbind

ipa user-add jupyterhub \
    --first='Jupyterhub' \
    --homedir=/syshome/jupyterhub \
    --uid=$((systemServiceGroup+3)) \
    --shell=/sbin/nologin \
    --gidnumber=$((systemServiceGroup+3)) \
    --last='Service'  \
    --class=SystemUser
ipa group-add-member systemservices --user jupyterhub

ipa user-add rstudio \
    --first='RStudio' \
    --homedir=/syshome/rstudio \
    --uid=$((systemServiceGroup+4)) \
    --shell=/sbin/nologin \
    --gidnumber=$((systemServiceGroup+4)) \
    --last='Service'  \
    --class=SystemUser
ipa group-add-member systemservices --user rstudio

echo "3.2.2  ambari, am_agent, ams, ambari-qa"


echo "## Ambari services"
ipa user-add ambari-server \
    --first='Server' \
    --homedir=/var/lib/ambari-server/keys/ \
    --uid=$((ambariServiceGroup+1)) \
    --shell=/sbin/nologin \
    --gidnumber=$((ambariServiceGroup+1)) \
    --last='Ambari' \
    --class=SystemUser
ipa group-add-member ambariservices --user ambari-server
#Ambari must be in hadoop group to read some keytabs when kerberos is used https://www.ibm.com/support/knowledgecenter/SSPT3X_4.2.0/com.ibm.swg.im.infosphere.biginsights.admin.doc/doc/admin_iop_server_kerberos.html
ipa group-add-member hadoop --user ambari-server

ipa user-add am_agent \
    --first='Agent' \
    --homedir=/syshome/am_agent \
    --uid=$((ambariServiceGroup+2)) \
    --shell=/bin/bash \
    --gidnumber=$((ambariServiceGroup+2)) \
    --last='Ambari' \
    --class=SystemUser
ipa group-add-member ambariservices --user am_agent

ipa user-add ams \
    --first='Metric Service' \
    --homedir=/syshome/ams \
    --uid=$((ambariServiceGroup+4)) \
    --shell=/sbin/nologin \
    --gidnumber=${hadoopGroup} \
    --last='Ambari' \
    --class=SystemUser \
    --noprivate
ipa group-add-member ambariservices --user ams
ipa group-add-member hadoop         --user ams

#Ambari places ambari-qa in the hadoop group, so there he stays
ipa user-add ambari-qa \
    --first='Smoke Test' \
    --homedir=/syshome/ambari-qa \
    --uid=$((ambariServiceGroup+5)) \
    --shell=/sbin/nologin \
    --gidnumber=${hadoopGroup} \
    --last='Ambari' \
    --class=SystemUser
ipa group-add-member nahusers       --user ambari-qa
ipa group-add-member ambariservices --user ambari-qa
ipa group-add-member hadoop         --user ambari-qa


echo "3.2.3  Hadoop users"


ipa user-add hdfs \
    --first="hdfs" \
    --homedir=/syshome/hdfs \
    --uid=${hdfsGroup} \
    --shell=/sbin/nologin \
    --gidnumber=${hdfsGroup} \
    --last='Apache' \
    --class=SystemUser \
    --noprivate
ipa group-add-member hadoop --user hdfs


#User list from
#http://docs.hortonworks.com/HDPDocuments/Ambari-2.5.0.3/bk_ambari-administration/content/defining_service_users_and_groups_for_a_hdp_2x_stack.html


ID=$hadoopGroup

echo "Most hadoop users do not need a personal group, so they are native members of the hadoop group"
function createHadoopUser(){
    local NAME=$1
    ID=$((ID+1))
    ipa user-add $NAME \
        --first="$NAME" \
        --homedir=/syshome/$NAME \
        --uid=$ID \
        --shell=/sbin/nologin \
        --gidnumber=${hadoopGroup} \
        --last='Apache' \
        --class=SystemUser \
        --noprivate
    ipa group-add-member hadoop --user $NAME
}

echo "Some hadoop services want a personal group, so create one and add them as members of the hadoop group."
function createHadoopUserWithGroup(){
    local NAME=$1
    ID=$((ID+1))
    ipa user-add $NAME \
        --first="$NAME" \
        --homedir=/syshome/$NAME \
        --uid=$ID \
        --shell=/sbin/nologin  \
        --gidnumber=$ID  \
        --last='Apache' \
        --class=SystemUser
    ipa group-add-member hadoop --user $NAME
}

createHadoopUser accumulo
createHadoopUser infra-solr
createHadoopUserWithGroup atlas
createHadoopUser falcon
createHadoopUser flume
createHadoopUser hbase
createHadoopUser hive
createHadoopUser hue
createHadoopUser kafka
createHadoopUserWithGroup knox
createHadoopUser mahout
createHadoopUser mapred
createHadoopUser oozie
createHadoopUserWithGroup ranger
createHadoopUserWithGroup kms
createHadoopUser slider
createHadoopUserWithGroup livy
createHadoopUserWithGroup spark1
createHadoopUserWithGroup spark2
createHadoopUser sqoop
createHadoopUser storm
createHadoopUser tez
createHadoopUser hcat
createHadoopUser yarn
createHadoopUser zeppelin
createHadoopUser zookeeper


echo "3.2.4  Syshomes"
echo "Create syshome folders for all system users"


echo "Ensure the user defs are up to date before using 'id'"
sss_cache -E

echo "## Create home dirs for all system users"
users=$(ipa user-find --class SystemUser | grep login: | cut -d':' -f2)

for user in $users; do
    echo $user
    mkdir -p "$SYSHOME_DIR/$user"
    chown $(id $user -u):$(id $user -g) $SYSHOME_DIR/$user -R
    ln -sf "$SYSHOME_DIR/$user" "/syshome/$user"
done

echo "3.3  Human Users"


echo "3.3.1  abrsadm"


USERNAME=abrsadm


ipa user-add $USERNAME \
    --first='Asger Askov' \
    --last='Blekinge' \
    --homedir=/autohome/$USERNAME \
    --uid=$((subadminsGroup+1)) \
    --shell=/bin/bash \
    --gidnumber=$((subadminsGroup+1)) \
    --class=SubAdmin \
    --email="abr@kb.dk"
ipa group-add-member subadmins --user $USERNAME
ipa group-add-member nahusers --user $USERNAME


sudo sss_cache -E
sudo mkdir -p $AUTOHOME_DIR/$USERNAME
sudo chown $USERNAME:$USERNAME $AUTOHOME_DIR/$USERNAME -R


USERNAME=vagrant


ipa user-add $USERNAME \
    --first='Vagrant' \
    --last='User' \
    --homedir=/home/$USERNAME \
    --uid=1000 \
    --shell=/bin/bash \
    --gidnumber=1000 \
    --class=SubAdmin \
    --email="vagrant@kb.dk"
ipa group-add-member subadmins --user $USERNAME
ipa group-add-member nahusers --user $USERNAME


echo "3.3.2  abr"

USERNAME=abr


ipa user-add $USERNAME \
    --first='Asger Askov' \
    --last='Blekinge' \
    --homedir=/autohome/$USERNAME \
    --uid=$((p000Group+1)) \
    --shell=/bin/bash \
    --gidnumber=$((p000Group+1)) \
    --class=NahUser \
    --email="abr@kb.dk"
ipa group-add-member nahusers --user $USERNAME
ipa group-add-member p000 --user $USERNAME

sudo sss_cache -E
sudo mkdir -p $AUTOHOME_DIR/$USERNAME
sudo chown $USERNAME:$USERNAME $AUTOHOME_DIR/$USERNAME -R

echo "3.4  Passwords"


sudo yum install -y expect

set_password vagrant vagrant123

#TODO something problem asking for password...

echo "Users to set password for"
echo "password_users="ldapbind,amad";"
password_users="abrsadm,abr,ldapbind,vagrant";

OLDIFS=$IFS
IFS=',';
for user in ${password_users}; do
    echo -e "\n\n$user";
    password=$(get_password "${user}")
    expect $SCRIPT_DIR/setUserPassword.exp "$user" "$password"
done

echo "3.5  Sudo rules"


set -o verbose #Print lines as they are executed
set -o nounset #Stop script if attempting to use an unset variable
#set -o errexit #Stop script if any command fails

echo " Ambari Customizable Users"
#ambari ALL=(ALL) NOPASSWD:SETENV: 
ambari_custom_users="/bin/su hdfs *,/bin/su ambari-qa *,/bin/su ranger *,/bin/su zookeeper *,/bin/su knox *,/bin/su falcon *,/bin/su ams *,/bin/su flume *,/bin/su hbase *,/bin/su spark1 *,/bin/su spark2 *,/bin/su accumulo *,/bin/su hive *,/bin/su hcat *,/bin/su kafka *,/bin/su mapred *,/bin/su oozie *,/bin/su sqoop *,/bin/su storm *,/bin/su tez *,/bin/su atlas *,/bin/su yarn *,/bin/su kms *,/bin/su activity_analyzer *,/bin/su livy *,/bin/su zeppelin *,/bin/su infra-solr *,/bin/su logsearch *,/bin/su root *"

echo " Ambari: Core System Commands"
#ambari ALL=(ALL) NOPASSWD:SETENV:
ambari_core_commands="/usr/bin/yum,/usr/bin/zypper,/usr/bin/apt-get,/bin/mkdir,/usr/bin/test,/bin/ln,/bin/ls,/bin/chown,/bin/chmod,/bin/chgrp,/bin/cp,/usr/sbin/setenforce,/usr/bin/stat,/bin/mv,/bin/sed,/bin/rm,/bin/kill,/bin/readlink,/usr/bin/pgrep,/bin/cat,/usr/bin/unzip,/bin/tar,/usr/bin/tee,/bin/touch,/usr/bin/mysql,/sbin/service mysqld *,/usr/bin/dpkg *,/bin/rpm *,/usr/sbin/hst *,/usr/bin/kinit *,/usr/bin/find *"

echo " Ambari: Hadoop and Configuration Commands"
#ambari ALL=(ALL) NOPASSWD:SETENV:
ambari_conf_commands="/usr/bin/hdp-select,/usr/bin/conf-select,/usr/hdp/current/hadoop-client/sbin/hadoop-daemon.sh,/usr/lib/hadoop/bin/hadoop-daemon.sh,/usr/lib/hadoop/sbin/hadoop-daemon.sh,/usr/bin/ambari-python-wrap *"

echo " Ambari: System User and Group Commands"
#ambari ALL=(ALL) NOPASSWD:SETENV:
ambari_usermanagement_commands="/usr/sbin/groupadd,/usr/sbin/groupmod,/usr/sbin/useradd,/usr/sbin/usermod"

echo " Ambari: Knox Commands"
#ambari ALL=(ALL) NOPASSWD:SETENV:
ambari_knox_commands="/usr/bin/python2.6 /var/lib/ambari-agent/data/tmp/validateKnoxStatus.py *,/usr/hdp/current/knox-server/bin/knoxcli.sh"

echo " Ambari: Ranger Commands"
#ambari ALL=(ALL) NOPASSWD:SETENV:
ambari_ranger_commands="/usr/hdp/*/ranger-usersync/setup.sh,/usr/bin/ranger-usersync-stop,/usr/bin/ranger-usersync-start,/usr/hdp/*/ranger-admin/setup.sh *,/usr/hdp/*/ranger-knox-plugin/disable-knox-plugin.sh *,/usr/hdp/*/ranger-storm-plugin/disable-storm-plugin.sh *,/usr/hdp/*/ranger-hbase-plugin/disable-hbase-plugin.sh *,/usr/hdp/*/ranger-hdfs-plugin/disable-hdfs-plugin.sh *,/usr/hdp/current/ranger-admin/ranger_credential_helper.py,/usr/hdp/current/ranger-kms/ranger_credential_helper.py,/usr/hdp/*/ranger-*/ranger_credential_helper.py"


echo " Ambari Infra and LogSearch Commands"
#ambari ALL=(ALL) NOPASSWD:SETENV:
ambari_solr_commands="/usr/lib/ambari-infra-solr/bin/solr *,/usr/lib/ambari-logsearch-logfeeder/run.sh *,/usr/sbin/ambari-metrics-grafana *,/usr/lib/ambari-infra-solr-client/solrCloudCli.sh *"


ambari_extra_commands="/bin/su root *"

commandGroups="ambari_custom_users,ambari_core_commands,ambari_conf_commands,ambari_usermanagement_commands,ambari_knox_commands,ambari_ranger_commands,ambari_solr_commands"

OLDIFS="$IFS"
IFS=','

ipa sudorule-add am_agent --hostcat='all' --runasusercat='all' --runasgroupcat='all'
ipa sudorule-add-user am_agent --users=am_agent
ipa sudorule-add-option am_agent --sudooption='!authenticate'
ipa sudorule-add-option am_agent --sudooption='setenv'
ipa sudorule-add-option am_agent --sudooption='exempt_group=am_agent'
ipa sudorule-add-option am_agent --sudooption='!requiretty'

for group in $commandGroups; do
    ipa sudocmdgroup-add "$group"
    groupCommands="${!group}"
    read -ra gca <<< "$groupCommands"

    for command in "${gca[@]}"; do
        ipa sudocmd-add "$command"
        ipa sudocmdgroup-add-member "$group" --sudocmds="$command"
    done
    ipa sudorule-add-allow-command am_agent --sudocmdgroups="$group"
    echo
done
echo
IFS="$OLDIFS"


#ipa sudorule-add smokeusers --hostcat="all" --runasusercat='all' --runasgroupcat='all'
#ipa sudorule-add-user smokeusers --users='ambari-qa'
#ipa sudorule-add-option smokeusers --sudooption='!authenticate'
#ipa sudorule-add-option smokeusers --sudooption='!requiretty'
#ipa sudocmdgroup-add 'smokeusers'
#ipa sudocmd-add '/usr/bin/kinit *'
#ipa sudocmdgroup-add-member 'smokeusers' --sudocmds='/usr/bin/kinit *'
#ipa sudorule-add-allow-command smokeusers --sudocmdgroups='smokeusers'


echo " Default sudo options"
ipa sudorule-add defaults --hostcat='all' --usercat='all'
ipa sudorule-add-option defaults --sudooption='!requiretty'
ipa sudorule-add-option defaults --sudooption='!env_reset'
ipa sudorule-add-option defaults --sudooption='env_delete-=PATH'


echo " subadmins sudorules"
ipa sudorule-add subadmins --hostcat="all" --cmdcat='all' --runasusercat='all' --runasgroupcat='all'
ipa sudorule-add-user subadmins --groups=subadmins
ipa sudorule-add-user subadmins --groups=admins
ipa sudorule-add-option subadmins --sudooption='!authenticate'
ipa sudorule-add-option subadmins --sudooption='!requiretty'


echo " jupyterhub sudorules"
ipa sudorule-add jupyterhub --hostcat='all' --runasusercat='all' --runasgroupcat='all'
ipa sudorule-add-user jupyterhub --users=jupyterhub
ipa sudorule-add-option jupyterhub --sudooption='!authenticate'
ipa sudorule-add-option jupyterhub --sudooption='!requiretty'
ipa sudocmdgroup-add 'jupyterhub'
ipa sudocmd-add '/usr/bin/sudospawner'
ipa sudocmdgroup-add-member 'jupyterhub' --sudocmds='/usr/bin/sudospawner'
ipa sudorule-add-allow-command jupyterhub --sudocmdgroups='jupyterhub'

