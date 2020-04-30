#!/usr/bin/env bash
#Export syshome dir via NFS.
SCRIPT_DIR=/vagrant/nah-adm

cd /vagrant/nah-adm
source ../common.sh
source ../machines.sh

mkdir -p $SYSHOME_DIR
#NFS exports this folder
append /etc/exports "$SYSHOME_DIR $IPRANGE1(rw,sec=sys,fsid=1339)"

#Make mount point
rm -df /syshome
ln -s $SYSHOME_DIR /syshome

#Autostart nfs on boot
systemctl enable nfs-server

#Restart to pick up config change
systemctl restart nfs-server



#2.4  Automounted Homes
#First configure automounting in FreeIPA on kac-adm


kinit_admin

#https://blog.delouw.ch/2015/03/14/using-ipa-to-provide-automount-maps-for-nfsv4-home-directories/

#This require the ipa admintools to be installed and the host to be an ipa client

#Add the NFS service principal for the server and client to Kerberos.
ipa service-add --force "nfs/$IPA_SERVER"

#Add the auto.home map
ipa automountmap-add default auto.home

#And add the auto.home map to auto.master
ipa automountkey-add default --key "/autohome" --info auto.home auto.master

#Finally add the key to the auto.home map
ipa automountkey-add default \
    --key "*" \
    --info "-fstype=nfs4,rw,sec=krb5,intr,hard $IPA_SERVER:$AUTOHOME_DIR/&" \
    auto.home



kinit_admin

#Get the keytab for the nfs process
ipa-getkeytab --server $IPA_SERVER -p "nfs/$IPA_SERVER" -k /etc/krb5.keytab

#Tell your NFS service to use NFSv4
perl -npe 's/#SECURE_NFS="yes"/SECURE_NFS=\"yes\"/g' -i /etc/sysconfig/nfs

#Create your NFS share and start the NFS server
mkdir -p $AUTOHOME_DIR
append /etc/exports "$AUTOHOME_DIR    $IPRANGE1(rw,sec=sys:krb5:krb5i:krb5p)"

#Make home folder for admin, the only user so far
#Ensure the user defs are up2date before resolving user/group names
sss_cache -E
mkdir -p $AUTOHOME_DIR/admin
chown admin:admins $AUTOHOME_DIR/admin

#Autostart nfs on boot
systemctl enable nfs-server

#Restart to pick up config change
systemctl restart nfs-server

#Then set up the automounting of homes

