#!/usr/bin/env bash

#keytabs must be run with kinit_admin creds
#distribute must be run with abrsadm creds, and standing in abrsadm home

IPA_HOST="$1"
shift

CSV="$1"
shift

function catLines(){
    #This strips the header line, if it is there
    cat $CSV | grep -v '^host,description'

    #Line format
    #1. host: ambari.kacv.sblokalnet
    #2. description: /spnego
    #3. principal name: HTTP/ambari.kacv.sblokalnet@KACV.SBLOKALNET
    #4. principal type: SERVICE
    #5. local username: ambari
    #6. keytab file path: /etc/security/keytabs/spnego.service.keytab
    #7. keytab file owner: root
    #8. keytab file owner access: r
    #9. keytab file group: hadoop
    #10. keytab file group access: r
    #11. keytab file mode: 440
    #12. keytab file installed: unknown

}
FHOST=1
FDESCRIPTION=2
FPRINCIPAL_NAME=3
FPRINCIPAL_TYPE=4
FLOCAL_USERNAME=5
FKEYTAB_FILE_PATH=6
FKEYTAB_FILE_OWNER=7
FKEYTAB_FILE_OWNER_ACCESS=8
FKEYTAB_FILE_GROUP=9
FKEYTAB_FILE_GROUP_ACCESS=10
FKEYTAB_FILE_MODE=11
FKEYTAB_FILE_INSTALLED=12

function hosts(){
    #echo "$hosts"
    hosts=$(catLines |cut -d',' -f${FHOST} | sort -u) # Parse the unique hosts from kerberos.csv
    echo "# Find unique hosts and add them to freeIPA"
    for host in ${hosts}; do
        echo "ipa host-add '${host}'"
    done
    echo ""
}

function services(){
    services=$(catLines | grep ',SERVICE,' | cut -d',' -f${FPRINCIPAL_NAME} | sort -u) # Parse the unique services from kerberos.csv
    #echo "$services"
    echo "# Find unique services and add them to freeIPA"
    for service in ${services}; do
        echo "ipa service-add '${service}'"
    done
    echo ""
}

function keytabs(){
    principals=$(catLines | cut -d',' -f${FPRINCIPAL_NAME} | sort -u) # Parse the unique principals from kerberos.csv
    #echo "$principals"

    echo "# Function to create keytab"
    echo "function ipa_get_keytab() {
        encodedName=\$(echo \${PRINCIPAL} | md5sum - | awk \"{print \\\$1}\")
        if [ ! -f \${encodedName} ]; then
            ipa-getkeytab --server=${IPA_HOST} --principal=\${PRINCIPAL} --keytab=\${encodedName}
        fi
        }"

    echo ""

    echo "# Create keytabs for all unique principals"
    for principal in ${principals}; do
        echo -e "PRINCIPAL=${principal}\t\t\t&& ipa_get_keytab"
    done
    echo ""
}

function distribute(){

    #Extract these fields
    local fields="$FHOST,$FPRINCIPAL_NAME,$FKEYTAB_FILE_PATH,$FKEYTAB_FILE_OWNER,$FKEYTAB_FILE_GROUP,$FKEYTAB_FILE_MODE"
    keytabs=$(catLines | cut -d',' -f${fields} | sort -u) # Parse the unique keytabs from the csv
    #echo "$keytabs"

    echo "# Function for uploading the keytab of a specific principal to a specific host, with the right permissions"

    echo "function upload(){
        ssh -T \${HOST} <<-EOF
            set -o nounset #Stop script if attempting to use an unset variable
            set -o errexit #Stop script if any command fails
            set -o verbose #Print lines as they are executed
            sudo mkdir -p /etc/security/keytabs
            encodedName=\$(echo \${PRINCIPAL} | md5sum - | awk \"{print \\\$1}\")
            sudo cp \$PWD/\\\$encodedName \${FILE}
            sudo chown \${OWNER}:\${GROUP} \${FILE}
            sudo chmod \${PERM} \${FILE}
	EOF
    }"

    echo "# Distribute all the keytabs to the specified hosts"
    for keytab_tuple in ${keytabs}; do
        #Bash tuples https://stackoverflow.com/a/36393986/4527948
        IFS=',' read host principal keytab owner group filemode <<< "${keytab_tuple}"
        echo "PRINCIPAL=${principal} \\"
        echo "HOST=${host} \\"
        echo "FILE=${keytab} \\"
        echo "PERM=${filemode} \\"
        echo "OWNER=${owner} \\"
        echo "GROUP=${group} \\"
        echo "&& upload"
        echo ""
    done
    echo ""
}



#echo "set -x"

for word in $*; do
    case $word in
    hosts)
        hosts
        ;;
    services)
        services
        ;;
    keytabs)
        keytabs
        ;;
    distribute)
        distribute
        ;;
    esac
done