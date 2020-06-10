FROM rightmesh/ubuntu-openjdk:16.04

ADD https://sbforge.org/nexus/service/local/repositories/releases/content/org/netarchivesuite/distribution/5.6/distribution-5.6.zip nas.zip
ADD https://sbforge.org/nexus/service/local/repositories/releases/content/org/netarchivesuite/heritrix3-bundler/5.6/heritrix3-bundler-5.6.zip h3bundler.zip

#ADD nas.zip nas.zip
#ADD h3bundler.zip h3bundler.zip

RUN apt-get update && apt-get install -y ca-certificates unzip postgresql-client python-setuptools python-pip && pip install -U pip && pip install -U setuptools && pip install j2cli

RUN unzip nas.zip -d nas
##RUN unzip h3bundler.zip
RUN touch /h3bundler.zip
RUN cp  /h3bundler.zip temp_h3bundler.zip  & true
RUN unzip temp_h3bundler.zip  & true
RUN mv heritrix-3* bundler   & true
RUN mv bundler/lib/* /nas/lib  & true
WORKDIR /nas

##COPY start.sh /nas/start.sh
##COPY settings.xml /nas/settings.xml
##COPY logback.xml /nas/logback.xml
COPY *.j2 /nas/
COPY wait-for-postgres.sh /nas/wait-for-postgres.sh
COPY jmxremote.password /nas/jmxremote.password
COPY docker-entrypoint.sh /
COPY h3server.jks /
RUN chmod 755 /nas/*.j2
RUN chmod 755 /nas/wait-for-postgres.sh
RUN chmod 755 /docker-entrypoint.sh
EXPOSE 8078

## CMD ["/nas/start.sh"]
CMD ["/docker-entrypoint.sh"]
