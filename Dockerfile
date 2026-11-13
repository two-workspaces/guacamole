# Apache Guacamole's web app for Railway: the official image plus a step that creates the
# PostgreSQL schema on the first boot and sets the admin login from variables, so the
# well-known guacadmin/guacadmin account never goes online.
FROM guacamole/guacamole:1.6.0
USER root
RUN apt-get update && apt-get install -y --no-install-recommends postgresql-client \
    && rm -rf /var/lib/apt/lists/*
COPY 050-railway-database.sh /opt/guacamole/entrypoint.d/
RUN chmod 644 /opt/guacamole/entrypoint.d/050-railway-database.sh
USER guacamole
