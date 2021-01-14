FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Env for UTF-8 language encoding
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

RUN apt-get update
RUN apt-get -y install software-properties-common
RUN apt-get -y install apache2
RUN apt-get -y install wget
RUN apt-get install less

# Install get-pip script
RUN wget https://bootstrap.pypa.io/get-pip.py

# Python3.6
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt-get -y install python3.6
RUN apt-get -y install python3.6-dev python3-distutils
RUN python3.6 get-pip.py

# Python3.7
RUN apt-get -y install python3.7
RUN apt-get -y install python3.7-dev
RUN python3.7 get-pip.py

# Python3.8
RUN apt-get -y install python3.8

# Python3.9
RUN apt-get -y install python3.9

# Apache settings
ENV APACHE_SERVER_NAME localhost
ENV APACHE_SSL_PORT 10444
ENV APPLICATION_URL https://${APACHE_SERVER_NAME}:${APACHE_SSL_PORT}
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
RUN mkdir -p $APACHE_RUN_DIR $APACHE_LOCK_DIR $APACHE_LOG_DIR

## Stuff for our specific scripts ##
RUN apt-get update && apt-get install -y mlocate
COPY scripts /scripts
RUN chmod 755 /scripts/*

COPY cgi-bin /usr/lib/cgi-bin
COPY apache2 /etc/apache2

## Copy CA Public Key
COPY certs/ca.crt /etc/ssl/certs
## Copy Server (pub and key)
COPY certs/server.crt /etc/ssl/certs/
COPY certs/server.key /etc/ssl/private/

RUN a2enmod cgi \
    && a2enmod ssl \
    && a2enmod headers \
    && a2ensite default-ssl \
    && c_rehash /etc/ssl/certs/

# Expose Apache
EXPOSE 80 ${APACHE_SSL_PORT}

ENTRYPOINT ["/usr/sbin/apache2ctl"]
CMD ["-D", "FOREGROUND"]