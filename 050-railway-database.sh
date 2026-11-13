#!/bin/bash
# Sourced by Guacamole's entrypoint before Tomcat starts (Railway addition).
# First boot: create the schema, then rename the default guacadmin account to
# ADMIN_USERNAME with ADMIN_PASSWORD, in one transaction.

railway_database() {
    [ -n "${POSTGRESQL_HOSTNAME:-}" ] || return 0
    local PGHOST="$POSTGRESQL_HOSTNAME" PGPORT="${POSTGRESQL_PORT:-5432}" \
          PGDATABASE="$POSTGRESQL_DATABASE" PGUSER="$POSTGRESQL_USERNAME" \
          PGPASSWORD="$POSTGRESQL_PASSWORD" PGCONNECT_TIMEOUT=5
    export PGHOST PGPORT PGDATABASE PGUSER PGPASSWORD PGCONNECT_TIMEOUT

    local i=0
    until psql -tAc 'SELECT 1' >/dev/null 2>&1; do
        i=$((i + 1))
        if [ "$i" -gt 90 ]; then
            echo "PostgreSQL at $PGHOST:$PGPORT isn't reachable:"; psql -tAc 'SELECT 1'; exit 1
        fi
        sleep 2
    done

    if [ "$(psql -tAc "SELECT to_regclass('public.guacamole_user') IS NOT NULL")" = t ]; then
        echo "Guacamole schema present"
        return 0
    fi

    : "${ADMIN_USERNAME:?Set ADMIN_USERNAME}"
    : "${ADMIN_PASSWORD:?Set ADMIN_PASSWORD}"
    echo "First boot: creating the Guacamole schema and the admin account $ADMIN_USERNAME"
    local salt
    salt=$(od -An -tx1 -N32 /dev/urandom | tr -d ' \n' | tr a-f A-F)
    {
        cat /opt/guacamole/extensions/guacamole-auth-jdbc/postgresql/schema/*.sql
        cat <<'SQL'
UPDATE guacamole_entity SET name = :'admin' WHERE name = 'guacadmin' AND type = 'USER';
UPDATE guacamole_user u
   SET password_salt = decode(:'salt', 'hex'),
       password_hash = sha256(convert_to(:'pw' || :'salt', 'UTF8')),
       password_date = CURRENT_TIMESTAMP
  FROM guacamole_entity e
 WHERE e.entity_id = u.entity_id AND e.name = :'admin' AND e.type = 'USER';
SQL
    } | psql -q -1 -v ON_ERROR_STOP=1 -v admin="$ADMIN_USERNAME" -v pw="$ADMIN_PASSWORD" -v salt="$salt" -f - \
        || { echo "Creating the schema failed"; exit 1; }
    echo "Admin account created"
}

railway_database
unset ADMIN_PASSWORD PGPASSWORD
