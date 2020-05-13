#!/usr/bin/env bash

SCRIPT_DIR=$(dirname $(readlink -f ${BASH_SOURCE[0]}))

#Script to ssh to vagrant host, rsync the config and setup the socks proxy

vagranthost=${1:-abr@abr-pc}
rsync -av $vagranthost:$SCRIPT_DIR/* $SCRIPT_DIR/ --ignore-existing --exclude=.vagrant

rsync -av $SCRIPT_DIR/* $vagranthost:$SCRIPT_DIR/ --delete


