#!/usr/bin/env bash
filename=$1
dir=$2
##database=tempdata/db.db
database=/db/db.db


if [ -z $dir ]; then
  locate --regex --basename -d $database "^$filename\$"
else
  locate --regex -d $database "/$dir/$filename\$"
fi