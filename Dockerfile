FROM alpine:3.10

RUN apk --no-cache add git curl openssh jq gettext

COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
