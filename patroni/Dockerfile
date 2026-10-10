FROM postgres:17-bookworm

# Patroni (from the PGDG repo already configured in the image) + pgvector
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      patroni \
      postgresql-17-pgvector \
      curl \
 && rm -rf /var/lib/apt/lists/*

COPY patroni.yml  /etc/patroni/patroni.yml
COPY post-init.sh /usr/local/bin/post-init.sh
RUN chmod 0755 /usr/local/bin/post-init.sh \
 && mkdir -p /var/lib/postgresql/data \
 && chown -R postgres:postgres /var/lib/postgresql /etc/patroni

USER postgres
EXPOSE 5432 8008
ENTRYPOINT ["patroni", "/etc/patroni/patroni.yml"]

