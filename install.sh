#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

source .env

# for traefik acme certs
mkdir -p ${STORAGE}/traefik/acme

# mmrs data dir
mkdir -p ${STORAGE}/mmrs/data
chown 82:82 ${STORAGE}/mmrs/data

# redis
mkdir -p ${STORAGE}/redis/data

# postgres
mkdir -p ${STORAGE}/postgres/data

# grafana persistent store
mkdir -p ${STORAGE}/grafana/data
chown 472:472 ${STORAGE}/grafana/data

# victoria metrics persistent store
mkdir -p ${STORAGE}/victoria/data
chown 1000:1000 ${STORAGE}/victoria/data

# synapse
mkdir -p ${STORAGE}/synapse/data/media_store
mkdir -p ${STORAGE}/synapse/config

# install the systemd unit file
cp ${REPO}/compose.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable compose
systemctl status compose
