#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username ${PG_ADMIN_USER} --dbname postgres <<-EOSQL
  DO $$ 
  BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '${AUTHENTIK_PG_USER}') THEN
      CREATE ROLE ${AUTHENTIK_PG_USER} WITH LOGIN;
    END IF;
  END

  ALTER USER ${AUTHENTIK_PG_USER} WITH PASSWORD '${AUTHENTIK_PG_PASS}';
  CREATE DATABASE IF NOT EXISTS ${AUTHENTIK_PG_DB};
  GRANT ALL PRIVILEGES ON DATABASE ${AUTHENTIK_PG_DB} TO ${AUTHENTIK_PG_USER};
EOSQL