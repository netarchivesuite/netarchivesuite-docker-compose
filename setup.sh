#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
RS=$DIR/bitmag-conf/service-conf/RepositorySettings.xml
cp $RS $DIR/bitmag-conf/service-conf/alarmservice
cp $RS $DIR/bitmag-conf/service-conf/audittrailservice
cp $RS $DIR/bitmag-conf/service-conf/service
cp $RS $DIR/bitmag-conf/service-conf/integrityservice
cp $RS $DIR/bitmag-conf/service-conf/monitoringservice
cp $RS $DIR/bitmag-conf/service-conf/webclient
cp $RS $DIR/kb-pillar
cp $RS $DIR/nasapp/nasclientconfig
