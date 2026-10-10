#!/bin/bash
# Called by Patroni once, right after the first primary is initialised.
# $1 = superuser connection string.
set -euo pipefail

psql "$1" -v ON_ERROR_STOP=1 \
  -v app_db="$APP_DB" -v app_user="$APP_USER" -v app_pw="$APP_PASSWORD" <<'SQL'
CREATE ROLE :"app_user" LOGIN PASSWORD :'app_pw';
CREATE DATABASE :"app_db" OWNER :"app_user";

-- make extensions available in every future database too
\c template1
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

\c :"app_db"
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
GRANT ALL ON SCHEMA public TO :"app_user";
SQL

echo "post-init: database '$APP_DB', user '$APP_USER' and pgvector ready"

