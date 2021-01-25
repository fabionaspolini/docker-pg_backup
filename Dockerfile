ARG PG_VERSION=13
FROM postgres:$PG_VERSION-alpine

COPY /scripts /scripts

RUN chmod +x /scripts/*.sh
RUN apk --update --no-cache add dcron

VOLUME /backups

WORKDIR /scripts
ENTRYPOINT ["/scripts/docker-entrypoint.sh"]
CMD ["/scripts/docker-cmd.sh"]
