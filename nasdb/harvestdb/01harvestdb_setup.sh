#!/usr/bin/env bash

echo Initialising database schema for harvestdb
psql --username "$POSTGRES_USER" -d harvestdb < ./01netarchivesuite_init.sql
echo Reading initial data for harvestdb
psql --username "$POSTGRES_USER" -d harvestdb < ./02harvestdb.testdata.sql
echo initialising adminDB
psql --username "$POSTGRES_USER" -d admindb < ./03createArchiveDB.pgsql

