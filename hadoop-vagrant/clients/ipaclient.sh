#!/usr/bin/env bash


SCRIPT_DIR=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
pushd $SCRIPT_DIR > /dev/null
source ../utils/machines.sh

set -e


mv /etc/resolv.conf /etc/resolv.conf.orig
cat > /etc/resolv.conf << EOC
search $DOMAIN_NAME1
nameserver $IPA_IP1
EOC




yum install -y ipa-client

set +e
ipa-client-install --uninstall --unattended
set -e

ipa-client-install \
    --domain=${DOMAIN_NAME1} \
    --server=${IPA_SERVER} \
    --realm=${REALM_NAME} \
    --ip-address=$(ip1) \
    --hostname=$(hostname -f) \
    --principal=admin \
    --password=$(get_password admin) \
    --unattended \
    --force-ntpd \
    --automount-location=default \
    --force-join

echo 'KRB5CCNAME=FILE:/tmp/krb5cc_$UID' > /etc/profile.d/kerberos.sh

sudo systemctl enable ntpd
sudo systemctl disable chronyd
sudo systemctl stop ntpd
sudo ntpdate $IPA_SERVER
sudo systemctl start ntpd

#Set the sudo timeout
sed -i "s|\(\[domain/\${DOMAIN_NAME1}\]\)|\1\nentry_cache_sudo_timeout = 10|g" /etc/sssd/sssd.conf

append /etc/nsswitch.conf "sudoers: files sss"

cp /etc/krb5.conf /etc/krb5.conf.old
cp /vagrant/clients/krb5.conf /etc/krb5.conf

kinit_admin

#First, get the IPs of this host
#host have been added to the DNS server during FreeIPA install, but not to the Reverse zone1, so the command ipa dnsrecord-add ${DOMAIN_NAME1} $(hostname -s) --a-rec=$(ip1) --a-create-reverse might fail, and the reverse entry not set up. So set this up.
set +e
ipa dnsrecord-add ${DOMAIN_NAME1} $(hostname -s) --a-rec=$(ip1) --a-create-reverse


#Assumes that the subnets are /24
REVERSE_ZONE1="$(echo "$SUBNET1" | awk -F. '{print $3"." $2"."$1}').in-addr.arpa."

#IP is like "10.0.0.9". This gets the 9. part
fourthPartOfIP=$(ip1 | cut -d'.' -f4)
ipa dnsrecord-add "${REVERSE_ZONE1}" "${fourthPartOfIP}" --ptr-rec="$(hostname -f)."
set -e
#Verify that the DNS server replies correctly for both direct and reverse lookups
host $(ip1) | grep -F $(hostname -f)
host "$(hostname -f)" | grep -F $(ip1)

#Ensure that this is the only dns server
sudo sed -i 's/nameserver 10.0.2.2//g' /etc/resolv.conf



#TODO firewall mod for NFS
#Make mount point
mkdir -p /syshome
# _netdev cause the mounting to wait for network to be up
append /etc/fstab "$IPA_SERVER:$SYSHOME_DIR      /syshome        nfs4    rw,defaults,_netdev,hard,intr,_netdev   0 0"

mount -a



## Search for automount, add sss to end if it does not exist in line #TODO nis=return can break this.
sudo sed -i 's|^automount:  files$|automount:  files sss|' /etc/nsswitch.conf
sudo grep automount /etc/nsswitch.conf


# The autofs service must be started before you can log in
sudo systemctl enable autofs
sudo systemctl restart autofs

popd > /dev/null
