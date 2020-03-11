FROM rightmesh/ubuntu-openjdk:16.04

ADD http://sbforge.org/nexus/content/repositories/releases/org/bitrepository/reference/bitrepository-reference-pillar/1.9.0.1/bitrepository-reference-pillar-1.9.0.1-distribution.tar.gz /pillar.tar.gz

RUN tar xvfz /pillar.tar.gz


ADD RepositorySettings.xml bitrepository-reference-pillar-1.9.0.1/conf

ADD ReferenceSettings.xml bitrepository-reference-pillar-1.9.0.1/conf

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
WORKDIR /bitrepository-reference-pillar-1.9.0.1
CMD bin/pillar.sh start && sleep infinity