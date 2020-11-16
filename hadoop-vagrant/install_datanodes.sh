#!/usr/bin/env bash

SCRIPT_DIR=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
pushd $SCRIPT_DIR > /dev/null

source install_common.sh

set -x

set -e

function setupDatanode(){
	local name=$1;
	sleep $[ ( $RANDOM % 10 )  + 1 ]s

	snapshot="2-clients"
	if ( vagrant snapshot list $name | grep $snapshot ); then
		vagrant snapshot restore --no-start $name $snapshot
		vagrant up $name
	else
		vagrant destroy -f $name;
		vagrant up $name;
		vagrant snapshot save $name "1-clean";
		vagrant sshfs $name;
		vagrant ssh --command 'sudo /vagrant/clients/ipaclient.sh' $name;
		vagrant ssh --command 'sudo /vagrant/clients/ambari_client.sh' $name;
		vagrant snapshot save $name $snapshot
	fi
}
export -f setupDatanode


echo "$DATANODES" | xargs -r -i -n 1 -P 3 bash -c 'setupDatanode "$@"' _ {}

popd > /dev/null
