FROM alpine:3.10

RUN apk --no-cache add git curl openssh jq gettext util-linux

COPY runcommand.sh /runcommand.sh
COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
