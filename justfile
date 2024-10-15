set positional-arguments
STORAGE := justfile_directory() / "storage"

# list the available recipes
list:
  just --list --justfile {{justfile()}}

# encrypt the secrets.yaml file into secrets.encrypted
encrypt:
  docker compose run --rm dcsm.purr encrypt

# decrypt the secrets.encrypted file into secrets.yaml
decrypt:
  docker compose run --rm dcsm.purr decrypt

# run DCSM, processing all templates using encrypted secrets
dcsm:
  docker compose run --rm dcsm.purr

# reload docker services
reload:
  git pull
  docker compose up --wait --detach --remove-orphans

# restart the specified service
restart service:
  docker compose restart {{service}}

# log output from all (or specified) service
logs service="":
  docker compose logs --follow --tail 100 {{service}}

# initialize postgres databases
postgres-init: dcsm
  docker compose exec -it postgres.purr /init_scripts/authentik_db.sh
  docker compose exec -it postgres.purr /init_scripts/synapse_db.sh
  docker compose exec -it postgres.purr /init_scripts/tandoor.sh
  docker compose exec -it postgres.purr /init_scripts/hedgedoc.sh

# make the directory structure for the storage volumes
mkdirs:
  #!/usr/bin/env bash
  set -euo pipefail
  #
  echo storage is {{STORAGE}}
  #
  # make sure the storage symlink is valid
  if [ -L {{STORAGE}} ];
  then
    if [ ! -e {{STORAGE}} ];
    then
      echo "storage symlink is invalid; please re-create it"
      exit 1
    fi
  else
    echo "storage symlink is missing; please create it"
    exit 1
  fi
  #
  # for traefik acme certs
  mkdir -p {{STORAGE}}/traefik/acme
  # mmrs data dir
  mkdir -p {{STORAGE}}/mmrs/data
  chown 82:82 {{STORAGE}}/mmrs/data
  # redis
  mkdir -p {{STORAGE}}/redis/data
  # postgres
  mkdir -p {{STORAGE}}/postgres/data
  # grafana persistent store
  mkdir -p {{STORAGE}}/grafana/data
  chown 472:472 {{STORAGE}}/grafana/data
  # victoria metrics persistent store
  mkdir -p {{STORAGE}}/victoria/data
  chown 1000:1000 {{STORAGE}}/victoria/data
  # synapse
  mkdir -p {{STORAGE}}/synapse/data/media_store
  mkdir -p {{STORAGE}}/synapse/config
  # mailman-web
  mkdir -p {{STORAGE}}/mailman.web/data
  chown -R 100:101 {{STORAGE}}/mailman.web/data
  # tandoor
  mkdir -p {{STORAGE}}/tandoor/media
  mkdir -p {{STORAGE}}/tandoor/static
  # mailman core
  mkdir -p {{STORAGE}}/mailman.core/var

firewall:
  # mailman-web to local mailman on the host
  ufw allow from 172.20.0.0/16 to 172.20.1.1 port 8001 proto tcp

# install the systemd service
install: mkdirs
  cp {{justfile_directory()}}/compose.service /etc/systemd/system/
  systemctl daemon-reload
  systemctl enable compose
  systemctl status compose
