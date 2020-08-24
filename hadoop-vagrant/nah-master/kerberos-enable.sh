#!/usr/bin/env bash

SCRIPT_DIR=$(dirname "$(readlink -f -- ${BASH_SOURCE[0]})")

pushd $SCRIPT_DIR > /dev/null
source ../utils/machines.sh

#https://cwiki.apache.org/confluence/display/AMBARI/Automated+Kerberizaton#AutomatedKerberizaton-TheRESTAPI

echo "Add the KERBEROS Service to cluster"
post  "clusters/$CLUSTER_NAME/services/KERBEROS"

echo "Add the KERBEROS_CLIENT component to the KERBEROS service"
post "clusters/$CLUSTER_NAME/services/KERBEROS/components/KERBEROS_CLIENT"

echo "Create and set KERBEROS service configurations"
put  "clusters/$CLUSTER_NAME" "@${SCRIPT_DIR}/kerberos-config.json"

echo "Query Ambari for the hadoop hosts"
hosts=$(get "hosts" |grep host_name| sed -n 's/.*"host_name" : "\([^\"]*\)".*/\1/p')
echo "Hadoop hosts identified as $hosts"

echo "Create the KERBEROS_CLIENT host components"
#_Once for each host, replace HOST_NAME_
for host in $hosts; do
    post "clusters/$CLUSTER_NAME/hosts?Hosts/host_name=$host" \
    '{"host_components" : [{"HostRoles" : {"component_name":"KERBEROS_CLIENT"}}]}'
done


echo "Install the KERBEROS service and components"
put  "clusters/$CLUSTER_NAME/services/KERBEROS" '{"ServiceInfo": {"state" : "INSTALLED"}}'



echo "Stop all services"
put  "clusters/$CLUSTER_NAME/services" '{"RequestInfo":{"context":"Stop Service"},"Body":{"ServiceInfo":{"state":"INSTALLED"}}}'




#Wait for Zookeeper to be stopped
while : ; do
   hdfsState=$(get "clusters/$CLUSTER_NAME/services/ZOOKEEPER" | jq '.ServiceInfo.state' -r)
   [[ "$hdfsState" = "Stopped" ]] || break
done




echo "Get the default Kerberos Descriptor"

#get "stacks/HDP/versions/2.6/artifacts/kerberos_descriptor"


#### Get the customized Kerberos Descriptor (if previously set)

#get "clusters/$CLUSTER_NAME/artifacts/kerberos_descriptor"

#### Set the Kerberos Descriptor


post "clusters/$CLUSTER_NAME/artifacts/kerberos_descriptor" '{"artifact_data" : {"properties": {"principal_suffix": ""}}}'

#### Enable Kerberos
put "clusters/$CLUSTER_NAME" '{"Clusters": {"security_type" : "KERBEROS"}}'


## PRODUCE THE KERBEROS CSV
get "clusters/$CLUSTER_NAME/kerberos_identities?fields=*&format=csv" > $SCRIPT_DIR/kerberos.csv




setConfig core-site "hadoop.security.authentication" "kerberos"
setConfig core-site "hadoop.security.authorization" "true"
#TODO use $REALM_NAME instead of NAH.HADOOP here
setConfig core-site "hadoop.security.auth_to_local" 'RULE:[2:$1@$0](nn@NAH.HADOOP)s/.*/hdfs/
RULE:[2:$1@$0](jn@NAH.HADOOP)s/.*/hdfs/
RULE:[2:$1@$0](dn@NAH.HADOOP)s/.*/hdfs/
RULE:[2:$1@$0](nm@NAH.HADOOP)s/.*/yarn/
RULE:[2:$1@$0](rm@NAH.HADOOP)s/.*/yarn/
RULE:[2:$1@$0](jhs@NAH.HADOOP)s/.*/mapred/
DEFAULT'


setConfig core-site "hadoop.proxyuser.ambari-server.groups" "nahusers"
setConfig core-site "hadoop.proxyuser.ambari-server.hosts" "$(hostname -f)"

setConfig hdfs-site "dfs.datanode.use.datanode.hostname" "true"
setConfig hdfs-site "dfs.client.use.datanode.hostname" "true"


setConfig yarn-site "yarn.timeline-service.http-authentication.simple.anonymous.allowed" "false"
setConfig yarn-site "yarn.resourcemanager.webapp.delegation-token-auth-filter.enabled" "true"
setConfig yarn-site "yarn.resourcemanager.proxyuser.*.groups" "nahusers"
setConfig yarn-site "yarn.resourcemanager.proxyuser.*.hosts " "$(hostname -f)"
setConfig yarn-site "yarn.timeline-service.http-authentication.cookie.domain"  "$(hostname -d)"
setConfig yarn-site "yarn.timeline-service.http-authentication.proxyuser.*.groups" "nahusers"
setConfig yarn-site "yarn.timeline-service.http-authentication.proxyuser.*.hosts" "$(hostname -f)"
setConfig yarn-site "yarn.timeline-service.http-authentication.signature.secret.file"  "/etc/security/http_secret"






# https://docs.cloudera.com/HDPDocuments/HDP3/HDP-3.1.0/authentication-with-kerberos/content/authe_spnego_configuring_http_authentication_for_hdfs_yarn_mapreduce2_hbase_oozie_falcon_and_storm.html

echo $hosts
dd if=/dev/urandom of=/vagrant/passwords/http_secret bs=1024 count=1
for host in $hosts; do
    echo "$host"
    sudo -u vagrant -i <<-EOS
      ssh -t "vagrant@$host" "sudo cp -f /vagrant/passwords/http_secret /etc/security/http_secret;
                            sudo chown hdfs:hadoop /etc/security/http_secret;
                            sudo chmod 440 /etc/security/http_secret"
EOS
done


setConfig core-site "hadoop.http.authentication.simple.anonymous.allowed" "false"
setConfig core-site "hadoop.http.authentication.signature.secret.file"  "/etc/security/http_secret"
setConfig core-site "hadoop.http.authentication.type" "kerberos"
setConfig core-site "hadoop.http.authentication.kerberos.keytab"  "/etc/security/keytabs/spnego.service.keytab"
setConfig core-site "hadoop.http.authentication.kerberos.principal"  "HTTP/_HOST@$REALM_NAME"
setConfig core-site "hadoop.http.filter.initializers"  "org.apache.hadoop.security.AuthenticationFilterInitializer"
setConfig core-site "hadoop.http.authentication.cookie.domain"  "$(hostname -d)"

setConfig core-site "hadoop.proxyuser.HTTP.groups" "nahusers"



kinit_admin
set -x

#https://github.com/apache/ambari/blob/branch-2.5/ambari-server/docs/security/kerberos/enabling_kerberos.md

source <(bash $SCRIPT_DIR/keytabs-create.sh $IPA_SERVER $SCRIPT_DIR/kerberos.csv hosts)

source <(bash $SCRIPT_DIR/keytabs-create.sh $IPA_SERVER $SCRIPT_DIR/kerberos.csv services)



sudo -u vagrant -i <<-EOF

source /vagrant/utils/machines.sh

mkdir -p /vagrant/keytabs
cd /vagrant/keytabs

kinit_admin

set -x

source <(bash $SCRIPT_DIR/keytabs-create.sh $IPA_SERVER $SCRIPT_DIR/kerberos.csv keytabs)


source <(bash $SCRIPT_DIR/keytabs-create.sh $IPA_SERVER $SCRIPT_DIR/kerberos.csv distribute)

EOF

sed -i 's/^kerberos.check.jaas.configuration=true/#kerberos.check.jaas.configuration=true/' /etc/ambari-server/conf/ambari.properties

sudo chown ambari-server:ambari-server /etc/security/keytabs/ambari.server.keytab
sudo ambari-server setup-security --security-option=setup-kerberos-jaas --jaas-principal=ambari-server@NAH.HADOOP --jaas-keytab=/etc/security/keytabs/ambari.server.keytab

sudo -i <<EOF
echo 'com.sun.security.jgss.krb5.initiate {
    com.sun.security.auth.module.Krb5LoginModule required
    renewTGT=false
    doNotPrompt=true
    useKeyTab=true
    keyTab="/etc/security/keytabs/ambari.server.keytab"
    principal="ambari-server@NAH.HADOOP"
    storeKey=true
    useTicketCache=false;
};
' > /etc/ambari-server/conf/krb5JAASLogin.conf
EOF

popd > /dev/null
