#!/bin/sh
# Renders pgbouncer.ini + userlist from env, then starts PgBouncer.
set -eu
CONF_DIR=/tmp/pgbouncer
mkdir -p "$CONF_DIR"

cat > "$CONF_DIR/pgbouncer.ini" <<EOF
[databases]
; read/write -> current primary
${APP_DB}    = host=haproxy port=5000 dbname=${APP_DB}
; read-only  -> replicas
${APP_DB}_ro = host=haproxy port=5001 dbname=${APP_DB}

[pgbouncer]
listen_addr = 0.0.0.0
listen_port = 6432
auth_type = scram-sha-256
auth_file = ${CONF_DIR}/userlist.txt
pool_mode = ${POOL_MODE}
max_client_conn = ${MAX_CLIENT_CONN}
default_pool_size = ${DEFAULT_POOL_SIZE}
min_pool_size = 5
reserve_pool_size = 10
reserve_pool_timeout = 3
server_reset_query = DISCARD ALL
server_check_query = select 1
server_check_delay = 10
server_lifetime = 3600
server_idle_timeout = 300
max_prepared_statements = 200
ignore_startup_parameters = extra_float_digits,options
admin_users = ${APP_USER}
stats_users = ${APP_USER}
log_connections = 0
log_disconnections = 0
EOF

printf '"%s" "%s"\n' "$APP_USER" "$APP_PASSWORD" > "$CONF_DIR/userlist.txt"
chmod 600 "$CONF_DIR/userlist.txt"

exec pgbouncer "$CONF_DIR/pgbouncer.ini"

