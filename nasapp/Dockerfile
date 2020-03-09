FROM rightmesh/ubuntu-openjdk:16.04


##FROM mlaccetti/docker-oracle-java8-ubuntu-16.04

##ADD https://sbforge.org/nexus/service/local/repositories/releases/content/org/netarchivesuite/distribution/5.2.2/distribution-5.2.2.zip  nas.zip
##ADD https://sbforge.org/nexus/service/local/repositories/releases/content/org/netarchivesuite/heritrix3-bundler/5.2.2/heritrix3-bundler-5.2.2.zip  h3bundler.zip
COPY nas.zip nas.zip
COPY h3bundler.zip h3bundler.zip

RUN apt-get update && apt-get install -y ca-certificates unzip postgresql-client python-setuptools && easy_install j2cli

RUN unzip nas.zip -d nas
RUN unzip h3bundler.zip
RUN mv heritrix-3* bundler
RUN mv bundler/lib/* /nas/lib
WORKDIR /nas

COPY *.j2 /nas/
COPY wait-for-postgres.sh /nas/wait-for-postgres.sh
COPY jmxremote.password /nas/jmxremote.password
COPY docker-entrypoint.sh /
COPY h3server.jks /
COPY nasclientconfig nasclientconfig
RUN chmod 755 /nas/*.j2
RUN chmod 755 /nas/wait-for-postgres.sh
RUN chmod 755 /docker-entrypoint.sh
EXPOSE 8078

CMD ["/docker-entrypoint.sh"]
