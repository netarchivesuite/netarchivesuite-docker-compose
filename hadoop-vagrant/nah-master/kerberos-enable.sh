#!/usr/bin/env bash


SCRIPT_DIR=/vagrant/nah-master
cd $SCRIPT_DIR
source ../common.sh
source ../machines.sh



#### Create the KERBEROS_CLIENT host components
#_Once for each host, replace HOST_NAME_

hosts=$(get "hosts" |grep host_name| sed -n 's/.*"host_name" : "\([^\"]*\)".*/\1/p')

for host in $hosts; do
    post "clusters/$CLUSTER_NAME/hosts?Hosts/host_name=$host" \
    '{"host_components" : [{"HostRoles" : {"component_name":"KERBEROS_CLIENT"}}]}'
done

#### Install the KERBEROS service and components
put  "clusters/$CLUSTER_NAME/services/KERBEROS" '{"ServiceInfo": {"state" : "INSTALLED"}}'




#### Stop all services

put  "clusters/$CLUSTER_NAME/services" '{"RequestInfo":{"context":"Stop Service"},"Body":{"ServiceInfo":{"state":"INSTALLED"}}}'


#### Get the default Kerberos Descriptor

get "stacks/HDP/versions/2.6/artifacts/kerberos_descriptor"


#### Get the customized Kerberos Descriptor (if previously set)

get "clusters/$CLUSTER_NAME/artifacts/kerberos_descriptor"

#### Set the Kerberos Descriptor


post "clusters/$CLUSTER_NAME/artifacts/kerberos_descriptor" '{"artifact_data" : {"properties": {"principal_suffix": ""}}}'

#### Enable Kerberos
put "clusters/$CLUSTER_NAME" '{"Clusters": {"security_type" : "KERBEROS"}}'


## PRODUCE THE KERBEROS CSV
get "clusters/$CLUSTER_NAME/kerberos_identities?fields=*&format=csv" > $SCRIPT_DIR/kerberos.csv





# https://docs.cloudera.com/HDPDocuments/HDP3/HDP-3.1.0/authentication-with-kerberos/content/authe_spnego_configuring_http_authentication_for_hdfs_yarn_mapreduce2_hbase_oozie_falcon_and_storm.html

dd if=/dev/urandom of=/vagrant/passwords/http_secret bs=1024 count=1

for host in $hosts; do
    echo "$host"
    ssh -t "vagrant@$host" "sudo cp /vagrant/passwords/http_secret /etc/security/http_secret;
                            sudo chown hdfs:hadoop /etc/security/http_secret;
                            sudo chmod 440 /etc/security/http_secret"
done


setConfig hdfs-site "hadoop.http.authentication.simple.anonymous.allowed" "false"
setConfig hdfs-site "hadoop.http.authentication.signature.secret.file"  "/etc/security/http_secret"
setConfig hdfs-site "hadoop.http.authentication.type" "kerberos"
setConfig hdfs-site "hadoop.http.authentication.kerberos.keytab"  "/etc/security/keytabs/spnego.service.keytab"
setConfig hdfs-site "hadoop.http.authentication.kerberos.principal"  "HTTP/_HOST@NAH.HADOOP"
setConfig hdfs-site "hadoop.http.filter.initializers"  "org.apache.hadoop.security.AuthenticationFilterInitializer"
setConfig hdfs-site "hadoop.http.authentication.cookie.domain"  "$(hostname -d)"






kinit_admin
set -x

#TODO how to get ambari to start kerberos creation programmatically
#https://github.com/apache/ambari/blob/branch-2.5/ambari-server/docs/security/kerberos/enabling_kerberos.md

source <(bash $SCRIPT_DIR/keytabs-create.sh $IPA_SERVER $SCRIPT_DIR/kerberos.csv hosts)

source <(bash $SCRIPT_DIR/keytabs-create.sh $IPA_SERVER $SCRIPT_DIR/kerberos.csv services)



sudo -u vagrant -i <<-EOF

source /vagrant/machines.sh

mkdir -p /vagrant/keytabs
cd /vagrant/keytabs

kinit_admin

source <(bash $SCRIPT_DIR/keytabs-create.sh $IPA_SERVER $SCRIPT_DIR/kerberos.csv keytabs)


source <(bash $SCRIPT_DIR/keytabs-create.sh $IPA_SERVER $SCRIPT_DIR/kerberos.csv distribute)

EOF
