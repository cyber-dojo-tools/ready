FROM alpine:latest
LABEL maintainer=jon@jaggersoft.com
RUN apk add bash curl gettext # envsubst
COPY --chown=nobody:nogroup . /app
ENTRYPOINT [ "/app/ready.sh" ]
