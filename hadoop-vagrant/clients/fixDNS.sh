#!/usr/bin/env bash

#This script sets up the DNS on the guest to correctly use the FreeIPA server, rather than the Virtualbox dns. This
# ensures that reverse lookups and the like function correctly

#When restoring from snapshots, the /vagrant folder might not be mounted yet, so do not depend on anything from there

dig -v || sudo yum install -y bind-utils

#IPA_SERVER=$(cat /etc/ipa/default.conf | grep server | cut -d' ' -f3)
#[ -z $IPA_SERVER ] && exit

#IPA_IP1=$(host $IPA_SERVER | cut -d' ' -f4)

IPA_IP1="10.0.0.9"
set -x

[ -f /etc/resolv.conf.orig ] || cp /etc/resolv.conf /etc/resolv.conf.orig;

cat /etc/resolv.conf
( (ss -l -u | grep -q -F "$IPA_IP1:domain") || (dig "@$IPA_IP1" $(hostname -f) +timeout=1 > /dev/null) ) && (

	echo "Decided to change resolv.conf"
    grep "^search .*$(hostname -d).*$" /etc/resolv.conf || sed -i -E "s/^(search .*)$/\1 $(hostname -d) /" /etc/resolv.conf;


    grep "^nameserver $IPA_IP1$" /etc/resolv.conf || echo "nameserver $IPA_IP1" >>/etc/resolv.conf ;

	sudo sed -i 's/nameserver 10.0.2.[0-9]//g' /etc/resolv.conf

	echo "new resolv.conf"
	cat /etc/resolv.conf

	) || true
