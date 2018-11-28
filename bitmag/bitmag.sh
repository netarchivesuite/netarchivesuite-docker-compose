#!/usr/bin/env bash

wget -N https://sbforge.org/nexus/content/repositories/releases/org/bitrepository/reference/bitrepository-integration/1.9/bitrepository-integration-1.9-quickstart.tar.gz

tar xvfz bitrepository-integration-1.9-quickstart.tar.gz

cp -r file1pillar file2pillar integrityservice RepositorySettings.xml bitrepository-quickstart/conf

cd bitrepository-quickstart

./setup.sh


