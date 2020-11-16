#!/usr/bin/env bash

#From https://fedoramagazine.org/using-the-networkmanagers-dnsmasq-plugin/

# This configures your system to use the dnsmasq plugin and to forward all requests to the .hadoop network to the freeipa server.
# This allows you host to resolve the vagrant hosts

#DO NOT DO THIS UNTIL nah-adm is up and running. In fact, wait until the cluster is up

#TODO check lookup via 10.0.0.9

sudo -i <<EOF
cat - > /etc/NetworkManager/conf.d/00-use-dnsmasq.conf <<-EOS
# /etc/NetworkManager/conf.d/00-use-dnsmasq.conf
#
# This enabled the dnsmasq plugin.
[main]
dns=dnsmasq
EOS

cat - > /etc/NetworkManager/dnsmasq.d/00-hadoop.conf <<-EOS
# /etc/NetworkManager/dnsmasq.d/00-hadoop.conf
#
# This file directs dnsmasq to forward any request to resolve
# names under the .homelab domain to 172.31.0.1, my
# home DNS server.
server=/hadoop/10.0.0.9
EOS
EOF


if [ $1 = "on" ]; then
    sudo sed -i 's/^\#dns=dnsmasq/dns=dnsmasq/' /etc/NetworkManager/conf.d/00-use-dnsmasq.conf
else
    sudo sed -i 's/^dns=dnsmasq/\#dns=dnsmasq/' /etc/NetworkManager/conf.d/00-use-dnsmasq.conf
fi

sudo systemctl restart NetworkManager
