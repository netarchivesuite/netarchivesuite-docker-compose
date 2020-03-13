## Running 

```
setup.sh
docker-compose -f docker-compose.yml -f docker-compose-bitmag-yml build
docker-compose -f docker-compose.yml -f docker-compose-bitmag-yml up
```

will create a complete dockerised NetarchiveSuite + Bitmagasin

* NetarchiveSuite GUI: http://localhost:8078
* Bitmagasin GUI: http://localhost:8180/bitrepository-webclient/status-service.html
* NetarchiveSuite ViewerProxy: localhost port 8878
* Java debugger for Heritrix (Focused): localhost port 8500
* Java debugger for Heritrix (Snapshot): localhost port 8501
 