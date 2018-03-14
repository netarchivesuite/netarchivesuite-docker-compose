FROM postgres:9.3

COPY harvestdb/0* docker-entrypoint-initdb.d/
COPY harvestdb/data/*  ./

RUN mkdir /tsindex
RUN chown postgres:postgres /tsindex