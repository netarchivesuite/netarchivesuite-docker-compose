#!/usr/bin/env bash

SCRIPT_DIR=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
pushd $SCRIPT_DIR > /dev/null
source ../utils/machines.sh

set -e

#Install java 8
yum install -y java-1.8.0-openjdk-devel

#Ambari Repo
yum install -y wget
wget -nv "$ambari_repo" -O /etc/yum.repos.d/ambari.repo
#yum clean all
#yum makecache

#Install ambari agent
yum install -y ambari-agent

sed -i 's/^run_as_user=.*$/run_as_user=am_agent/g' /etc/ambari-agent/conf/ambari-agent.ini
sed -i 's/^hostname=.*$/hostname='"$MASTER_NAME"'/g' /etc/ambari-agent/conf/ambari-agent.ini

#Fix ssl errors
entry="force_https_protocol=PROTOCOL_TLSv1_2"
grep -q "'$entry'" /etc/ambari-agent/conf/ambari-agent.ini || sed -i "s/\(\[security\]\)/\1\n$entry/" /etc/ambari-agent/conf/ambari-agent.ini
sed -i 's/^verify=.*$/verify=disable/' /etc/python/cert-verification.cfg





sudo mkdir -p /var/lib/ambari-agent/
sudo chown am_agent:am_agent /var/lib/ambari-agent/ -R

sudo mkdir -p /var/log/ambari-agent/
sudo chown am_agent:am_agent /var/log/ambari-agent/ -R

sudo mkdir -p /var/run/ambari-agent/
sudo chown am_agent:am_agent /var/run/ambari-agent/ -R

systemctl enable ambari-agent

systemctl restart ambari-agent

popd > /dev/null
