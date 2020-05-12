#! /bin/bash

echo Started clearing bitmag

COLLECTION=netarkivet
BASEDIR=$(dirname $0)
CONFDIR="/nas/nasclientconfig"
PILLARS="file1-pillar"

listing=$(mktemp)
trap "rm -f $listing" 0 2 3 5

java -cp "/nas/lib/*" org.bitrepository.commandline.GetChecksumsCmd -c netarkivet -s $CONFDIR > $listing

 while read line; do
    if [[ $line != *":"* ]]; then
     arr=($line)
     for PILLAR in $PILLARS; do
       java -cp "/nas/lib/*" org.bitrepository.commandline.DeleteFileCmd -c netarkivet -s $CONFDIR -p $PILLAR -i ${arr[2]} -C ${arr[0]}
     done
    fi
 done < $listing

 echo Finished clearing bitmag
