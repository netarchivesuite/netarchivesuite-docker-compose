## Prototype python-cgi script for accessing warc-records.

Start server with 

     docker-compose -f docker-compose-wrs.yml up

Then read a warc-record with 

    curl -r "3442-" "http://localhost:8883/cgi-bin2/py1.cgi/10-4-20161218234343407-00000-kb-test-har-003.kb.dk.warc.gz?foo=bar&x=y"
    
 Also test error handling with e.g. the wrong offset or filename