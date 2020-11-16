#! /bin/bash

echo Started clearing bitmag

COLLECTION=netarkivet
BASEDIR=$(dirname $0)
CONFDIR="/nas/nasclientconfig"
PILLARS="kb-pillar"

listing=$(mktemp)
trap "rm -f $listing" 0 2 3 5

for f in $(find /nas -type f -name "*.j2"); do
    echo -e "Evaluating template\n\tSource: $f\n\tDest: ${f%.j2}"
    j2 $f > ${f%.j2}
    rm -f $f
done

cp /nas/logback.xml /nas/lib

java -cp "/nas/lib/*" -Dlogback.configurationFile=/nas/logback.xml org.bitrepository.commandline.GetChecksumsCmd -c $COLLECTION -s $CONFDIR > $listing
echo Found files:
cat $listing

 while read line; do
    if [[ $line != *":"* ]]; then
     arr=($line)
     for PILLAR in $PILLARS; do
       echo "Deleting ${arr[2]} from $PILLAR"
       java -cp "/nas/lib/*" -Dlogback.configurationFile=/nas/logback.xml org.bitrepository.commandline.DeleteFileCmd -c $COLLECTION -s $CONFDIR -p $PILLAR -i ${arr[2]} -C ${arr[0]}
     done
    fi
 done < $listing
 echo Finished clearing bitmag


for file in /nas/testdata/*; do
    echo "Uploading $file"
    java -cp "/nas/lib/*" -Dlogback.configurationFile=/nas/logback.xml org.bitrepository.commandline.PutFileCmd -c $COLLECTION -s $CONFDIR -f $file
done

echo Finished uploading test data
##sleep  1d
