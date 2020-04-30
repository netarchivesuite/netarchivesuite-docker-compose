#!/bin/bash
#
# login.sh $USERNAME $PASSWORD

#this script doesn't work if it is run as root, since then we don't have to specify a pw for 'su'
if [ $(id -u) -eq 0 ]; then
        echo "This script can't be run as root." 1>&2
        exit 1
fi

if [ ! $# -eq 2 ]; then
        echo "Wrong Number of Arguments (expected 2, got $#)" 1>&2
        exit 1
fi

USERNAME=$1
PASSWORD=$2

# Setting the language to English for the expected "Password:" string, see http://askubuntu.com/a/264709/18014
export LC_ALL=C

#since we use expect inside a bash-script, we have to escape tcl-$.
expect << EOF
spawn su $USERNAME -c "exit"
expect "Password:"
send "$PASSWORD\r"
#expect eof

set wait_result  [wait]

# check if it is an OS error or a return code from our command
#   index 2 should be -1 for OS erro, 0 for command return code
if {[lindex \$wait_result 2] == 0} {
        exit [lindex \$wait_result 3]
}
else {
        exit 1
}
EOF