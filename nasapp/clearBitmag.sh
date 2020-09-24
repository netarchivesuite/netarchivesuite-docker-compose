#! /bin/bash

echo Started clearing bitmag

COLLECTION=netarkivet
BASEDIR=$(dirname $0)
CONFDIR="/nas/nasclientconfig"
PILLARS="kb-pillar"
LOGGING="-Dlogback.configurationFile=$CONFDIR/logback.xml"

listing=$(mktemp)
trap "rm -f $listing" 0 2 3 5

java -cp "/nas/lib/*" $LOGGING org.bitrepository.commandline.GetChecksumsCmd -c $COLLECTION -s $CONFDIR > $listing
echo Found files:
cat $listing

 while read line; do
    if [[ $line != *":"* ]]; then
     arr=($line)
     for PILLAR in $PILLARS; do
       echo "Deleting ${arr[2]} from $PILLAR"
       java -cp "/nas/lib/*" $LOGGING org.bitrepository.commandline.DeleteFileCmd -c $COLLECTION -s $CONFDIR -p $PILLAR -i ${arr[2]} -C ${arr[0]}
     done
    fi
 done < $listing
 echo Finished clearing bitmag


for file in /nas/testdata/*; do
    echo "Uploading $file"
    java -cp "/nas/lib/*" $LOGGING org.bitrepository.commandline.PutFileCmd -c $COLLECTION -s $CONFDIR -f $file
done

echo Finished uploading test data
