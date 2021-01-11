#!/usr/bin/env bash
filename=$1
dir=$2
##database=tempdata/db.db
database=/db/db.db


if [ -z $dir ]; then
  locate -n 1 --regex --basename -d $database "^$filename\$"
else
  locate -n 1 --regex -d $database "/$dir/$filename\$"
fi