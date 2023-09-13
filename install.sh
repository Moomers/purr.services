#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

source .env

# for traefik acme certs
mkdir -p ${STORAGE}/traefik/acme

# for the cloudflare credentials
if [ ! -f "${STORAGE}/traefik/cloudflare.env" ]
then
  echo "Please create ${STORAGE}/traefik/cloudflare.env with the following content:"
  echo "CLOUDFLARE_DNS_API_TOKEN=..."
  exit 1
fi

# mmrs data dir
mkdir -p ${STORAGE}/mmrs/data
chown 82:82 ${STORAGE}/mmrs/data

# redis
mkdir -p ${STORAGE}/redis/data

# postgres
mkdir -p ${STORAGE}/postgres/data
if [ ! -f "${STORAGE}/postgres/env" ]
then
  echo "Please create ${STORAGE}/postgres/env with the following content:"
  echo "POSTGRES_USER=..."
  echo "POSTGRES_PASSWORD=..."
  exit 1
fi

# authentik config
mkdir -p ${STORAGE}/authentik/media ${STORAGE}/authentik/templates
if [ ! -f "${STORAGE}/authentik/env" ]
then
  echo "Please create ${STORAGE}/authentik/env with the following content:"
  echo "AUTHENTIK_POSTGRESQL__USER=..."
  echo "AUTHENTIK_POSTGRESQL__PASSWORD=..."
  echo "AUTHENTIK_POSTGRESQL__NAME=..."
  echo "AUTHENTIK_SECRET_KEY=..."

  exit 1
fi


# install the systemd unit file
cp ${REPO}/compose.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable compose
systemctl status compose
