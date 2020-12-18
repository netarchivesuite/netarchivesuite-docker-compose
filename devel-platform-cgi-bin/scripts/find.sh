#!/usr/bin/env bash
regex=$1
dir=$2
database=/var/www/cgi-bin/db.db

if [ -z $dir ]; then
  locate --regex --basename -d $database $1
else
  if [[ ${regex:0:1} == "^" ]] ; then
    regex=${regex:1}  ## doesn't make sense to have a "^" not at the start
  fi
  fullregex="/$dir/$regex"
  locate --regex -d $database $fullregex
fi
