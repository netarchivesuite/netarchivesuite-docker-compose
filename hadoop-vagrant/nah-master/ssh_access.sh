#!/usr/bin/env bash
SCRIPT_DIR=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
pushd $SCRIPT_DIR > /dev/null
source ../utils/machines.sh


hosts=$(get "hosts" |grep host_name| sed -n 's/.*"host_name" : "\([^\"]*\)".*/\1/p')


#Allow vagrant passwordless ssh access to all hosts as vagrant
sshpass -V || sudo yum install -y sshpass

sudo -u vagrant -i <<-EOF
	[ -e \$HOME/.ssh/id_rsa ] || ssh-keygen -t rsa -b 4096 -C "\$USER@\$(hostname -f)" -f \$HOME/.ssh/id_rsa -N ""
	echo "$hosts" | \
		xargs -r -i sshpass -p "vagrant123" ssh-copy-id "vagrant@{}"
EOF

popd > /dev/null
