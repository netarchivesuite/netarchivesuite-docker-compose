#!/usr/bin/env bash

while [ true ]
do
   echo "Updating db"
   updatedb --require-visibility 0 -U /kbhpillar/collection-netarkivet/ -o /db/db.db
   sleep 3s
done