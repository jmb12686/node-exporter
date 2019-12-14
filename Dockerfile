## Build stage - Build node-exporter from latest source
FROM golang:alpine as builder

RUN apk update && apk add --no-cache git && \
    apk add --no-cache make && \
    apk add --no-cache gcc && \
    apk add --no-cache curl && \
    apk add --no-cache libc-dev && \
    apk add --no-cache bash

RUN mkdir -p $GOPATH/src/github.com/prometheus/node_exporter && \
    git clone --branch v0.18.1 --depth 1 https://github.com/prometheus/node_exporter.git $GOPATH/src/github.com/prometheus/node_exporter
WORKDIR $GOPATH/src/github.com/prometheus/node_exporter
RUN make build

## Run stage - Install dependencies and copy node-exporter from builder
FROM alpine 

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

LABEL maintainer="John Belisle" \
  org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.name="node-exporter" \
  org.label-schema.description="Containerized, multiarch node-exporter for use in Docker Swarm and Prometheus " \
  org.label-schema.version=$VERSION \
  org.label-schema.url="https://github.com/jmb12686/node-exporter" \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.vcs-url="https://github.com/jmb12686/node-exporter" \
  org.label-schema.vendor="jmb12686" \
  org.label-schema.schema-version="1.0"

COPY --from=builder go/src/github.com/prometheus/node_exporter/node_exporter /bin/node_exporter

ENV NODE_ID=none

USER root

COPY conf /etc/node-exporter/
RUN ["chmod", "+x", "/etc/node-exporter/docker-entrypoint.sh"]

EXPOSE      9100
ENTRYPOINT  [ "/etc/node-exporter/docker-entrypoint.sh" ]
CMD [ "/bin/node_exporter" ]
