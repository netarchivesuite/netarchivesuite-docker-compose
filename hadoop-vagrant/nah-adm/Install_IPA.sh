#!/usr/bin/env bash

SCRIPT_DIR=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
pushd $SCRIPT_DIR > /dev/null
source ../utils/machines.sh

setenforce 0

#Install IPA server
#First install haveged for entropy, as this speeds up the install A LOT
#https://blog-ftweedal.rhcloud.com/2014/05/more-entropy-with-haveged/
# Should fix the entropy problem
yum install -y epel-release
yum install -y haveged
systemctl enable haveged.service
systemctl start haveged.service

#Then install ipa server
yum install -y ipa-server ipa-server-dns ipa-server-trust-ad

#Setup IPA Server
#Setup the FreeIPA server



#Reset resolv.conf so that dns works.
sed -i "s/nameserver $IPA_IP1//" /etc/resolv.conf

ipa-server-install \
    --unattended \
    --realm="${REALM_NAME}" \
    --domain="${DOMAIN_NAME1}" \
    --ds-password="$(get_password dm)" \
    --admin-password="$(get_password admin)" \
    --hostname="$IPA_SERVER" \
    --ip-address="$IPA_IP1" \
    --idstart="${usersGroup}" \
    --setup-dns \
	--no-reverse \
    --auto-forwarders

systemctl enable ipa
sudo systemctl enable ntpd
sudo systemctl disable chronyd
sudo systemctl start ntpd


append /etc/nsswitch.conf "sudoers: files sss"

#Move Admin user UID and GID to correct values
#The user admin is created automatically with the uid and gid specified with idstart above.
# We use idstart to denote where ordinary human users' uid should start. So we have to move the admin user to the right values now.


kinit_admin

ipa user-show admin

ipa group-add admins    --gid ${adminsGroup}    --desc='Account administrators group'
# If group-add fails, it is most likely because the group is already added, so try to mod instead
ipa group-mod admins    --gid ${adminsGroup}

ipa user-mod admin    --uid ${adminsGroup} --gid ${adminsGroup}

ipa user-show admin

#Reverse DNS
#Add the reverse zones for subnet1 and subnet2.


kinit_admin

#https://docs.pagure.org/bind-dyndb-ldap/BIND9/SyncPTR.html
ipa dnszone-mod $(hostname -d). --dynamic-update=TRUE
ipa dnszone-mod $(hostname -d). --update-policy="grant $(hostname -d). krb5-self * A; grant $(hostname -d). krb5-self * AAAA; grant $(hostname -d). krb5-self * SSHFP;"
ipa dnszone-mod $(hostname -d). --allow-sync-ptr=TRUE

#Assumes that the subnets are /24
REVERSE_ZONE1="$(echo "$SUBNET1" | awk -F. '{print $3"." $2"."$1}').in-addr.arpa."

ipa dnszone-add $REVERSE_ZONE1 --dynamic-update=TRUE

#First, get the IPs of this host
#host have been added to the DNS server during FreeIPA install, but not to the Reverse zone1, so the command ipa dnsrecord-add ${DOMAIN_NAME1} $(hostname -s) --a-rec=$(ip1) --a-create-reverse might fail, and the reverse entry not set up. So set this up.
set +e
ipa dnsrecord-add $(hostname -d). $(hostname -s) --a-rec=$(ip1) --a-create-reverse

#IP is like "10.0.0.9". This gets the 9. part
fourthPartOfIP=$(ip1 | cut -d'.' -f4)
ipa dnsrecord-add "${REVERSE_ZONE1}" "${fourthPartOfIP}" --ptr-rec="$(hostname -f)."
set -e
#Verify that the DNS server replies correctly for both direct and reverse lookups
host $(ip1) | grep -F $(hostname -f)
host "$(hostname -f)" | grep -F $(ip1)

popd > /dev/null
