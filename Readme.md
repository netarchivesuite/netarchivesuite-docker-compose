## Running
 
First build NetarchiveSuite from the bitmag branch:
```
csr@oates:~/projects/netarchivesuite$ mvn -DskipTests clean package
```
Then copy the two distribution zips from Netarchivesuite to the docker project
```
cp ./deploy/distribution/target/NetarchiveSuite-5.7-IIPCH3-SNAPSHOT.zip ../netarchivesuite-docker-compose/nasapp/nas.zip
cp ./harvester/heritrix3/heritrix3-bundler/target/NetarchiveSuite-heritrix3-bundler-5.7-IIPCH3-SNAPSHOT.zip ../netarchivesuite-docker-compose/nasapp/h3bundler.zip
```


```
setup.sh
docker-compose -f docker-compose.yml -f docker-compose-bitmag.yml -f docker-compose-wrs.yml build
docker-compose -f docker-compose.yml -f docker-compose-bitmag.yml -f docker-compose-wrs.yml up
```

will create a complete dockerised NetarchiveSuite + Bitmagasin

* NetarchiveSuite GUI: http://localhost:8078
* Bitmagasin GUI: http://localhost:8180/bitrepository-webclient/status-service.html
* NetarchiveSuite ViewerProxy: localhost port 8878
* Java debugger for Heritrix (Focused): localhost port 8500
* Java debugger for Heritrix (Snapshot): localhost port 8501
 
(Note: the last three are currently commented out in the docker compose file.)

Any files in the nasapp/testdata folder will be uploaded to bitmag.

In addition there is a WarcRecordService endpoint on localhost:8883 on which any uploaded compressed warc-files should 
be accessible. E.g. on

```
curl -r "3442-" "http://localhost:8883/cgi-bin2/py1.cgi/10-4-20161218234343407-00000-kb-test-har-003.kb.dk.warc.gz?foo=bar&x=y"
```                     

