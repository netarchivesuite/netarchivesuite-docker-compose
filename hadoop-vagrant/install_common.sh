#!/usr/bin/env bash

export DATANODES="nah-data-001
nah-data-002
nah-data-003"

function doOrRestore(){
    local name="$1"
    shift
    local snapshot="$1"
    shift
    set -e
    if ( vagrant snapshot list "$name" | grep "$snapshot" ); then
        vagrant snapshot restore --no-start "$name" "$snapshot"
    else
        if ! (vagrant status $name | grep -q "$name\s+running"); then
            vagrant reload $name
        fi
        for command in "$@"; do
            vagrant ssh --command "$command" "$name"
        done
        vagrant snapshot save "$name" "$snapshot"
    fi
}

#TODO domain name hardcoded...
function syncNTP(){
	vagrant ssh --command 'sudo systemctl stop ntpd; sudo ntpdate nah-adm.nah.hadoop; sudo systemctl start ntpd' $1
}