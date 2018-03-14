#!/usr/bin/env bash
echo Starting linux application: ArcRepository
export CLASSPATH=/nas/lib/netarchivesuite-monitor-core.jar:/nas/lib/netarchivesuite-harvester-core.jar:/nas/lib/netarchivesuite-archive-core.jar:$CLASSPATH;
java -Xmx1024m  -Ddk.netarkivet.settings.file=/nas/settings.xml -Dlogback.configurationFile=/nas/logback.xml dk.netarkivet.archive.arcrepository.ArcRepositoryApplication
