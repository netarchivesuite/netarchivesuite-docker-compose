FROM pyohei/python-cgi
RUN apt-get update &&  apt install -y mlocate

COPY scripts /scripts

RUN chmod 755 /scripts/*
