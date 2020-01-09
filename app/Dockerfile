FROM alpine:latest
LABEL maintainer=jon@jaggersoft.com
RUN apk add bash curl gettext jq # envsubst
RUN wget -O /usr/local/bin/yq \
  "https://github.com/mikefarah/yq/releases/download/2.4.1/yq_linux_amd64" \
  && chmod +x /usr/local/bin/yq
COPY --chown=nobody:nogroup . /app
ENTRYPOINT [ "/app/ready.sh" ]
