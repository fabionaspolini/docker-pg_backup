FROM postgres:12-alpine

COPY /scripts /

RUN apk --update --no-cache add dcron

VOLUME /backups

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/docker-cmd.sh"]
