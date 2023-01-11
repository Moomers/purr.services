#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

source .env

# for traefik acme certs
mkdir -p ${STORAGE}/traefik/acme

# install the systemd unit file
cp ${REPO}/compose.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable compose
systemctl status compose
