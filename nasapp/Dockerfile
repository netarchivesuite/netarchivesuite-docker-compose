FROM ubuntu:16.04

RUN apt-get update && apt-get install -y software-properties-common build-essential git openjdk-8-jre openjdk-8-jdk  && add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && apt-get install -y python3.6 python3.6-dev python3-pip

RUN ln -sfn /usr/bin/python3.6 /usr/bin/python3 && ln -sfn /usr/bin/python3 /usr/bin/python && ln -sfn /usr/bin/pip3 /usr/bin/pip

RUN apt-get update && apt-get install -y ca-certificates unzip postgresql-client python-setuptools && pip install -U pip && pip install -U setuptools && pip install j2cli


ADD https://sbforge.org/nexus/service/local/repositories/releases/content/org/netarchivesuite/distribution/6.0/distribution-6.0.zip nas.zip
ADD https://sbforge.org/nexus/service/local/repositories/releases/content/org/netarchivesuite/heritrix3-bundler/6.0/heritrix3-bundler-6.0.zip h3bundler.zip

#ADD nas.zip nas.zip
#ADD h3bundler.zip h3bundler.zip

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
