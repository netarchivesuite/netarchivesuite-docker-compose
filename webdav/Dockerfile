# VERSION 0.1
# AUTHOR:         Asger Askov Blekinge <asger.askov.blekinge@gmail.com>
# DESCRIPTION:    apache2 configured as WebDAV

FROM debian:jessie
MAINTAINER Asger Askov Blekinge <asger.askov.blekinge@gmail.com>

# Update & install packages
RUN apt-get update;\
    apt-get -y install apache2 apache2-utils

RUN mkdir -p /site/dav && \
    chown www-data:www-data /site/dav

#VOLUME /site/dav/

ADD 000-default.conf /etc/apache2/sites-available/000-default.conf
RUN a2enmod dav dav_fs dav_lock # Enable DAV

RUN echo "export APACHE_RUN_USER=docker" >> /etc/apache2/envvars && \
    echo "export APACHE_RUN_GROUP=docker" >> /etc/apache2/envvars

EXPOSE 80

COPY dockerEntry.sh /dockerEntry.sh
ENTRYPOINT ["/dockerEntry.sh"]

CMD ["/usr/sbin/apachectl", "-D", "FOREGROUND"]
