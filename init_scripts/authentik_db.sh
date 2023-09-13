#!/bin/bash
set -e

psql="psql -v ON_ERROR_STOP=1 --username ${POSTGRES_USER} --dbname postgres"

# we might need to create role and DB
exists=`$psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='${AUTHENTIK_POSTGRESQL__USER}'"`
if [ "$exists" != "1" ]; then
  $psql -tAc "CREATE ROLE ${AUTHENTIK_POSTGRESQL__USER} WITH LOGIN;"
  $psql -tAc "CREATE DATABASE ${AUTHENTIK_POSTGRESQL__NAME} WITH OWNER ${AUTHENTIK_POSTGRESQL__USER};"
  $psql -tAc "GRANT ALL PRIVILEGES ON DATABASE ${AUTHENTIK_POSTGRESQL__NAME} TO ${AUTHENTIK_POSTGRESQL__USER};"
fi

# support password changes
$psql -tac "ALTER USER ${AUTHENTIK_POSTGRESQL__USER} WITH PASSWORD '${AUTHENTIK_POSTGRESQL__PASSWORD}';"
