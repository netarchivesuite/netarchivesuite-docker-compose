#!/usr/bin/env bash

while [ true ]
do
   echo "Updating db"
   updatedb --require-visibility 0 -U /netarkivet/ -o /db/db.db
   sleep 3s
done