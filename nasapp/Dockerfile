FROM rightmesh/ubuntu-openjdk:16.04

ADD https://sbforge.org/nexus/service/local/repositories/releases/content/org/netarchivesuite/distribution/7.3/distribution-7.3.zip nas.zip
ADD https://sbforge.org/nexus/service/local/repositories/releases/content/org/netarchivesuite/heritrix3-bundler/7.3/heritrix3-bundler-7.3.zip h3bundler.zip

# To test a different NAS release, replace the above two lines with these two lines and copy your distribution zips
# to nas.zip and h3bundler.zip in this directory
# ADD nas.zip nas.zip
# ADD h3bundler.zip h3bundler.zip

ADD https://bootstrap.pypa.io/pip/3.5/get-pip.py get-pip.py
RUN apt-get update && apt-get install -y ca-certificates unzip postgresql-client python-setuptools python3-pip && python3 get-pip.py && pip3 install j2cli
RUN apt-get update && apt-get install -y less && apt-get install -y iputils-ping

RUN unzip nas.zip -d nas
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
