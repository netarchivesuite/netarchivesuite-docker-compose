#!/usr/bin/env bash
regex=$1
dir=$2
if [ -z $dir ]; then
  locate --regex --basename -d /db/db.db $1
else
  fullregex='/'$dir'/'$regex
  locate --regex -d /db/db.db $fullregex
fi
