### Running NetarchiveSuite Quickstart

##### Very Quick Start

`docker-compose build`

`docker container rm netarchivesuite-docker-compose_ftp_1 & docker-compose up`

will create a complete dockerised NetarchiveSuite with GUI on http://localhost:8078 and viewerproxy on localhost port 8878

In addition, a java debugger can be attached to the heritrix processes on port 8500 (Focused) or 8501 (Snapshot) and the
NetarchiveSuite database will be exposed on port 6543.

For more information on using NetarchiveSuite, see the [Quickstart Manual](8878l).

#### More About This Docker-Compose Assembly

The assembly starts a complete NetarchiveSuite installation consisting of 15 containers. Three of these containers are services used by NetarchiveSuite (jms-broker, ftp-server, postgres database) and the other 12 are a network of NetarchiveSuite applications. In a production environment, these 12 applications would run on multiple machines, possibly widely geographically distributed.

Each NetarchiveSuite application instance is based on the Dockerfile defined in the "nasapp" directory. Each application uses the same distribution of NetarchiveSuite software whose location is defined inside the Dockerfile. These can either be fetched from our nexus installation, or provided by the user - for example in order to test self-developed code.

The individual applications are defined by customising three jinja2 template files - start.sh.j2, settings.xml.j2, and logback.xml.j2. It is no coincidence that we use the same templating engine as ansible, as there is a long-standing ambition to develop an ansible-playbook deployment of NetarchiveSuite.

The docker-compose.yml defines environment variables for the templating of each of the 12 containers. The actual call to the jinja2 command line (j2) comes from the docker-entrypoint.sh script.

The installation emulates a NetarchiveSuite setup distributed over two geographic locations ("S" and "K"). In particular there is an instance of BitarchiveApplication at each of the two locations. Such a setup enables a geographically distributed bitpreservation environment.

The environment also defines two harvesters, each with its own harvesting channel - ("FOCUSED" and "SNAPSHOT"). The database configuration loaded in the nasdb container maps the "SNAPSHOT" channel to broad crawls - that is crawls of all known domains. In a realistic setup there could be many harvesters on many machines in multiple geographic locations.