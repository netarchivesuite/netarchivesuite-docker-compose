#!/usr/bin/env bash
#set -o verbose #Print lines as they are executed
#set -o nounset #Stop script if attempting to use an unset variable
#set -o errexit #Stop script if any command fails

#General values for all hosts
export SUBNET1="10.0.0"
export IPRANGE1="${SUBNET1}.0/24"
export DOMAIN_NAME1="nah.hadoop"
export REALM_NAME="NAH.HADOOP"

export CLUSTER_NAME="NAH"

export LDAP_DOMAIN="dc=nah,dc=hadoop"

export STO_DATA_DIR=/sto-data
export SYSHOME_DIR="$STO_DATA_DIR/syshome"
export AUTOHOME_DIR="$STO_DATA_DIR/home"

export DATANODES="nah-data-001.$DOMAIN_NAME1
nah-data-002.$DOMAIN_NAME1
nah-data-003.$DOMAIN_NAME1"

export hadoopGroup=11000
export hdfsGroup=11200
export systemServiceGroup=15000
export ambariServiceGroup=16000
export bigInsightsServiceGroup=17000
export subadminsGroup=12000
export adminsGroup=13000
export usersGroup=20000
export p000Group=100
export p001Group=200
export p002Group=300
export p003Group=400

# from http://docs.hortonworks.com/HDPDocuments/Ambari-2.5.0.3/bk_ambari-installation/content/ambari_repositories.html
export ambari_repo="http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.5.0.3/ambari.repo"




export passwordDir=/vagrant/passwords
function get_password {
    local PASSFILE="$1"

    if [[ "${PASSFILE}" != /* ]]; then
        #Relative path
        PASSFILE="${passwordDir}/${PASSFILE}"
    fi

    if [ -e "${PASSFILE}" ]; then
        cat "${PASSFILE}"
    else
        mkdir -p "${passwordDir}"
        local PASSWD=${2:-$(openssl rand -base64 12)}
        echo "${PASSWD}" > "${PASSFILE}"
        echo "${PASSWD}"
    fi
}
export get_password
export set_password=get_password

function kinit_admin {
    klist -s  || (get_password admin | kinit "admin@$REALM_NAME")
}
export kinit_admin



# Append line to file, if file does not already contain that line
function append(){
    local FILE="$1"
    shift
    local LINE="$@"
    grep -q "$LINE" "$FILE" 2>/dev/null || echo "$LINE" >> "$FILE"
}


#Set up the databases we need
function createDB(){
    DATABASE="$1"
    DBUSER="$2"
    DBPASSWD="$(get_password postgres_${DBUSER})"

    cd /tmp/
    echo "CREATE DATABASE $DATABASE;" | sudo -u postgres psql
    echo "CREATE USER $DBUSER WITH PASSWORD '$DBPASSWD';" | sudo -u postgres psql
    echo "GRANT ALL PRIVILEGES ON DATABASE $DATABASE TO $DBUSER;" | sudo -u postgres psql
}


function ip1(){
    ip addr show eth1 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1 | sed -s 's/\s//g'
}



function get(){
    local path="$1"
    curl -s -H "X-Requested-By: ambari" -X GET -u "admin:$adminPass" "http://$MASTER_NAME:8080/api/v1/$path"
}

function delete(){
    local path="$1"
    curl -q -s -H "X-Requested-By: ambari" -X DELETE -u "admin:$adminPass" "http://$MASTER_NAME:8080/api/v1/$path"
}


function post(){
    local path="$1"
    local body="${2:-null}"
    curl -s -H "X-Requested-By: ambari" -X POST -u "admin:$adminPass" "http://$MASTER_NAME:8080/api/v1/$path" -d "$body"
}


function put(){
    local path="$1"
    local body="${2:-null}"
    curl -s -H "X-Requested-By: ambari" -X PUT -u "admin:$adminPass" "http://$MASTER_NAME:8080/api/v1/$path" -d "$body"
}


adminPass=$(get_password admin)



function setConfig(){
	pushd $HOME > /dev/null
    /var/lib/ambari-server/resources/scripts/configs.py \
        --user=admin \
        --password=$(get_password admin) \
        --host=$(hostname) \
        --port=8080 \
        --protocol=http \
        --action=set \
        --cluster=$CLUSTER_NAME \
        --config-type="$1" \
        --key="$2" \
        --value="$3"
    popd > /dev/null
}


function waitForComponentStatus(){
	local component=$1
	local desiredState=$2
	echo "Wait for $component  to be $desiredState"
	while : ; do
	   local actualState=$(get "clusters/$CLUSTER_NAME/services/$component" | jq '.ServiceInfo.state' -r)
	   [[ "$actualState" = "$desiredState" ]] && break
	   sleep 5
	done
}

