#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
	CREATE USER datastore_default;
	CREATE DATABASE datastore_default;
	GRANT ALL PRIVILEGES ON DATABASE datastore_default TO ckan_default;
    GRANT ALL PRIVILEGES ON DATABASE datastore_default TO datastore_default;
EOSQL
command="ALTER USER datastore_default PASSWORD '${POSTGRES_PASSWORD}';"
psql --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -c "${command}"