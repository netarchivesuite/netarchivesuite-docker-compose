FROM alpine
RUN apk add mlocate
RUN apk add bash
COPY scripts /scripts
RUN chmod 755 /scripts/*

CMD ["/scripts/update.sh"]