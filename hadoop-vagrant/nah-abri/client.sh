#!/usr/bin/env bash

set -e
cd /vagrant/nah-abri
source ../common.sh
source ../machines.sh



mv /etc/resolv.conf /etc/resolv.conf.orig
cat > /etc/resolv.conf << EOC
search $DOMAIN_NAME1
nameserver $KAC_ADM_IP1
EOC




set -x
yum install -y ipa-client

set +e
ipa-client-install --uninstall --unattended
set -e

ipa-client-install \
    --domain=${DOMAIN_NAME1} \
    --server=${KAC_ADM} \
    --realm=${REALM_NAME} \
    --ip-address=$KAC_ABRI_IP1 \
    --principal=admin \
    --password=$(get_password admin) \
    --unattended \
    --force-join

#Set the sudo timeout
sed -i "s|\(\[domain/\${DOMAIN_NAME1}\]\)|\1\nentry_cache_sudo_timeout = 10|g" /etc/sssd/sssd.conf

#Set the kerberos tickets so hadoop can read them
sed -i "s|default_ccache_name.*|default_ccache_name = /tmp/krb5cc_%{uid}|g" /etc/krb5.conf

append /etc/nsswitch.conf "sudoers: files sss"


kinit_admin
#ipa dnsrecord-add ${DOMAIN_NAME1} $(hostname -s) --a-rec=$KAC_ABRI_IP1 --a-create-reverse






#TODO firewall mod for NFS
#Make mount point
mkdir -p /syshome
# _netdev cause the mounting to wait for network to be up
append /etc/fstab "$KAC_ADM:$SYSHOME_DIR      /syshome        nfs4    rw,defaults,_netdev,hard,intr,_netdev   0 0"

mount -a



# Finally you need to configure your client systems to map use of the automount maps provided by IPA
sudo ipa-client-automount --uninstall
sudo ipa-client-automount --location=default --server=${KAC_ADM} --unattended

## Search for automount, add sss to end if it does not exist in line #TODO nis=return can break this.
sudo sed -i 's|^automount:  files$|automount:  files sss|' /etc/nsswitch.conf
sudo grep automount /etc/nsswitch.conf


# The autofs service must be started before you can log in
sudo systemctl enable autofs
sudo systemctl restart autofs
