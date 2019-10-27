# node-exporter
<p align="center">
  <a href="https://hub.docker.com/r/jmb12686/node-exporter/tags?page=1&ordering=last_updated"><img src="https://img.shields.io/github/v/tag/jmb12686/node-exporter?label=version&style=flat-square" alt="Latest Version"></a>
  <a href="https://github.com/jmb12686/node-exporter/actions"><img src="https://github.com/jmb12686/node-exporter/workflows/build/badge.svg" alt="Build Status"></a>
  <a href="https://hub.docker.com/r/jmb12686/node-exporter/"><img src="https://img.shields.io/docker/stars/jmb12686/node-exporter.svg?style=flat-square" alt="Docker Stars"></a>
  <a href="https://hub.docker.com/r/jmb12686/node-exporter/"><img src="https://img.shields.io/docker/pulls/jmb12686/node-exporter.svg?style=flat-square" alt="Docker Pulls"></a>
</p>

Containerized, multiarch version of node-exporter, used for [Prometheus](https://prometheus.io/) monitoring.  Multi-stage build is used to build from official [node-exporter source code](github.com/prometheus/node_exporter).  Designed to be usable within x86-64, arm64, armv6, and armv7 based Docker Swarm clusters.  Added support for correct reporting of the underlying node hostname

## Automated Build and Deploy
This repository utilizes GitHub Actions to automatically build and deploy multiarch images to DockerHub when a new tag is pushed.

## Build and Deploy multiarch image locally

Setup local environment to support Docker experimental feature for building multi architecture images, [buildx](https://docs.docker.com/buildx/working-with-buildx/).  Follow instructions [here](https://engineering.docker.com/2019/04/multi-arch-images/)

Clone repo:
```bash
$ git clone https://github.com/jmb12686/node-exporter
$ cd node-exporter 
```

Build multiarch image:
```bash
$ docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v6 -t jmb12686/node-exporter:latest --push .
```

## Usage

Use in docker-compose swarm stack similar to base image for `prom/node-exporter`, but added:
* `NODE_ID` as environment variable
* mount `/etc/hostname` of underlying host to `/etc/nodename` in the container.  
* Entrypoint script within container will use `/etc/nodename` and `NODE_ID` to create custom data attributes and put config in `/etc/node-exporter`.
* `node-name` and `node-id` attributes are exposed in node-exporter


```yaml
services:
  .....
  node-exporter:
    image: jmb12686/node-exporter:latest 
    networks:
      - net
    environment:
      - NODE_ID={{.Node.ID}}
    ports:
      - 9100:9100
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
      - /etc/hostname:/etc/nodename:ro
    command:
      - '--path.sysfs=/host/sys'
      - '--path.procfs=/host/proc'
      - '--path.rootfs=/rootfs'
      - '--collector.textfile.directory=/etc/node-exporter/'
      - '--collector.filesystem.ignored-mount-points=^/(sys|proc|dev|host|etc)($$|/)'
      - '--no-collector.ipvs'
    deploy:
      mode: global
      resources:
        limits:
          memory: 32M
```



