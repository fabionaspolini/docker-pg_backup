ARG PG_VERSION=13
FROM postgres:$PG_VERSION-alpine

COPY /scripts /

RUN chmod +x /pgpass_gen.sh
RUN apk --update --no-cache add dcron

VOLUME /backups

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/docker-cmd.sh"]
