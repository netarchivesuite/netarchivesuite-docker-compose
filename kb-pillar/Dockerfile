FROM rightmesh/ubuntu-openjdk:16.04

RUN apt-get update && apt-get -y install zip less jsvc

## Download zip-file from http://code-01.kb.dk:8082/nexus/content/repositories/releases/dk/kb/bitrepository/pillar-frontend/1.3.3/pillar-frontend-1.3.3.zip
ADD pillar-frontend-1.3.3.zip /pillar.zip

RUN unzip /pillar.zip

RUN mv kb-pillar-1.3.3 /kb-pillar

RUN mkdir /kb-pillar/conf

ADD RepositorySettings.xml /kb-pillar/conf
ADD BackendSettings.xml /kb-pillar/conf
ADD FrontendSettings.xml /kb-pillar/conf
ADD log4j.properties /kb-pillar/conf

RUN sed -i "s/\"no\"/\"yes\"/" /kb-pillar/bin/kb-pillar
RUN sed -i "s/\"no\"/\"yes\"/" /kb-pillar/bin/kb-pillar-backend

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
WORKDIR /kb-pillar

CMD ["/kb-pillar/bin/kb-pillar", "start", "&&", "sleep infinity"]
