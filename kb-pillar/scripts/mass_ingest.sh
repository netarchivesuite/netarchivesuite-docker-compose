#!/usr/bin/env bash

BITMAG_DIR=/kbhpillar/netarkivet
##BITMAG_DIR=bitmag
SQL_BATCHFILE=sqlbat.sql
##echo "PRAGMA foreign_keys=OFF" >$SQL_BATCHFILE
##echo "BEGIN TRANSACTION;" >>$SQL_BATCHFILE
##echo "CREATE TABLE files (file_id VARCHAR2(4000) PRIMARY KEY UNIQUE NOT NULL, backend VARCHAR2(512) NOT NULL,file_path VARCHAR2(512) NOT NULL,file_size INTEGER NOT NULL,mtime DATETIME NOT NULL);" >>$SQL_BATCHFILE

for i in {1..100}
  do
    FILE=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
    cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1 >$BITMAG_DIR/$FILE
    echo "INSERT INTO \"files\" VALUES('$FILE','Backend-100','$FILE',100,1602077200160);" >>$SQL_BATCHFILE
  done
##echo "COMMIT;" >>$SQL_BATCHFILE

