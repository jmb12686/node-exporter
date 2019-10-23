FROM prom/node-exporter

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

ENV NODE_ID=none

USER root

COPY conf /etc/node-exporter/

ENTRYPOINT  [ "/etc/node-exporter/docker-entrypoint.sh" ]
CMD [ "/bin/node_exporter" ]
