## Running
 
First build NetarchiveSuite from the bitmag branch:
```
csr@oates:~/projects/netarchivesuite$ mvn -DskipTests clean package
```
Then copy the two distribution zips from NetarchiveSuite (referred to as NAS) to the docker project (referred to as NAS-DC)
```
cp <NAS>/deploy/distribution/target/NetarchiveSuite-5.7-IIPCH3-SNAPSHOT.zip <NAS-DC>/nasapp/nas.zip
cp <NAS>/harvester/heritrix3/heritrix3-bundler/target/NetarchiveSuite-heritrix3-bundler-5.7-IIPCH3-SNAPSHOT.zip <NAS-DC>/nasapp/h3bundler.zip
```

If using Hadoop for mass processing also copy the shaded uber jar to the docker project:
```
cp <NAS>/hadoop-uber-jar/target/hadoop-uber-jar-5.7-IIPCH3-SNAPSHOT-shaded.jar <NAS-DC>/nasapp/hadoop-uber-jar.jar
```

To use the kb-pillar for Bitmag storage, download the zip-file from http://code-01.kb.dk:8082/nexus/content/repositories/releases/dk/kb/bitrepository/pillar-frontend/1.3.3/pillar-frontend-1.3.3.zip
and place it in the kb-pillar directory such that it has the path
```
<NAS-DC>/kb-pillar/pillar-frontend-1.3.3.zip
```

Running the following
```
setup.sh
docker-compose -f docker-compose.yml -f docker-compose-bitmag.yml -f docker-compose-wrs.yml build
docker-compose -f docker-compose.yml -f docker-compose-bitmag.yml -f docker-compose-wrs.yml up
```

will then create a complete dockerised NetarchiveSuite + Bitmagasin

* NetarchiveSuite GUI: http://localhost:8078
* Bitmagasin GUI: http://localhost:8180/bitrepository-webclient/status-service.html
* NetarchiveSuite ViewerProxy: localhost port 8878
* Java debugger for Heritrix (Focused): localhost port 8500
* Java debugger for Heritrix (Snapshot): localhost port 8501
 
(Note: the last three are currently commented out in the docker compose file.)

Any files in the nasapp/testdata folder will be uploaded to bitmag.

In addition there is a WarcRecordService endpoint on https://localhost:10433 on which any uploaded compressed warc-files should 
be accessible. E.g. on

```
curl --cert-type P12 --cert test-client.p12:test -r "3442-" "http://localhost:8883/cgi-bin2/py1.cgi/10-4-20161218234343407-00000-kb-test-har-003.kb.dk.warc.gz?foo=bar&x=y"
curl --cert-type P12 --cert test-client.p12:test http://localhost:8884/cgi-bin2/fileresolver.cgi/1*
```                     

### Renew certificates for fileresolver/wrs
```
# 1. Create new CA cert and key
openssl req -x509 -newkey rsa:4096 -keyout ca.key -out ca.crt -sha256 -days 3650 -nodes
# 2. Renew client cert
openssl x509 -req -days 3650 -sha256 -in test-client.csr -CA ca.crt -CAkey ca.key -set_serial 2 -out test-client.crt
# 3. Update pem- and p12-file with new cert
cat test-client.crt test-client.key > test-client.pem
openssl pkcs12 -export -inkey test-client.key -in test-client.crt -out test-client.p12
```
Repeat step 2 and 3 using `fileresolver-server` or `wrs-server` instead of `test-client` to renew server certs.
Generating p12-files can be skipped if you just want to use pem-files (already how certs are provided for the servers).
