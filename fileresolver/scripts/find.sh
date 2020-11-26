#!/usr/bin/env bash
regex=$1
dir=$2
if [ -z $dir ]; then
  locate --regex --basename -d /db/db.db $1
else
  if [[ ${str:0:1} == "/" ]] ; then
    fullregex='/'$dir'/'$regex
  else
    fullregex='/'$dir$regex
  fi
  locate --regex -d /db/db.db $fullregex
fi
