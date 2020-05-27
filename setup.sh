#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

NETWORK=netarkivet-net
PACKAGE=$DIR/kb-pillar/pillar-frontend-1.3.3.zip
URL=http://code-01.kb.dk:8082/nexus/content/repositories/releases/dk/kb/bitrepository/pillar-frontend/1.3.3/pillar-frontend-1.3.3.zip

echo "For clean start >docker system prune -a"
echo "Creating docker network $NETWORK if necessary"
docker network create netarkivet-net 2>/dev/null 1>/dev/null || true

if [ -f $PACKAGE ]; then
    echo "$PACKAGE already exists, so not downloading"
else
     echo "Downloading $PACKAGE from $URL. This requires internal KB network access."
     wget -O $PACKAGE $URL
fi


RS=$DIR/bitmag-conf/service-conf/RepositorySettings.xml
echo "Distributing repository settings from $DIR"
cp $RS $DIR/bitmag-conf/service-conf/alarmservice
cp $RS $DIR/bitmag-conf/service-conf/audittrailservice
cp $RS $DIR/bitmag-conf/service-conf/service
cp $RS $DIR/bitmag-conf/service-conf/integrityservice
cp $RS $DIR/bitmag-conf/service-conf/monitoringservice
cp $RS $DIR/bitmag-conf/service-conf/webclient
cp $RS $DIR/kb-pillar
cp $RS $DIR/nasapp/nasclientconfig
