FROM mlaccetti/docker-oracle-java8-ubuntu-16.04

ADD https://sbforge.org/nexus/service/local/repositories/releases/content/org/netarchivesuite/distribution/5.2.2/distribution-5.2.2.zip  nas.zip
ADD https://sbforge.org/nexus/service/local/repositories/releases/content/org/netarchivesuite/heritrix3-bundler/5.2.2/heritrix3-bundler-5.2.2.zip  h3bundler.zip
RUN apt-get update && apt-get install -y unzip postgresql-client

RUN unzip nas.zip -d nas
RUN unzip h3bundler.zip
RUN mv heritrix-3* bundler
RUN mv bundler/lib/* /nas/lib
WORKDIR /nas

COPY start.sh /nas/start.sh
COPY settings.xml /nas/settings.xml
COPY logback.xml /nas/logback.xml
COPY wait-for-postgres.sh /nas/wait-for-postgres.sh
COPY jmxremote.password /nas/jmxremote.password
RUN chmod 755 /nas/start.sh
RUN chmod 755 /nas/wait-for-postgres.sh


CMD ["/nas/start.sh"]
