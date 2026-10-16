#!/usr/bin/env bash
# Debian/Ubuntu. Run as root: sudo ./setup.sh
set -euo pipefail

PG_VERSION=18
DB=mydb

[[ $EUID -eq 0 ]] || { echo "run as root" >&2; exit 1; }
export DEBIAN_FRONTEND=noninteractive

# psql as the postgres OS user (peer auth over unix socket, no password needed)
pg() {
  sudo -u postgres psql -v ON_ERROR_STOP=1 "$@";
}

# echo "==> install nginx"
# apt-get update -qq
# apt-get install -y nginx
# systemctl enable --now nginx

echo "==> add PGDG repo + install postgresql-${PG_VERSION}"
apt-get install -y postgresql-common ca-certificates
/usr/share/postgresql-common/pgdg/apt.postgresql.org.sh -y
apt-get install -y "postgresql-${PG_VERSION}"

echo "==> start postgresql"
systemctl enable --now postgresql

echo "==> wait until ready"
for _ in {1..30}; do
  pg_isready -q && break
  sleep 1
done
pg_isready || { echo "postgres not ready" >&2; exit 1; }

echo "==> assert psql connectivity + version"
[[ "$(pg -tAc 'SELECT 1')" == "1" ]] || { echo "connect failed" >&2; exit 1; }
[[ "$(pg -tAc "SHOW server_version_num")" == ${PG_VERSION}* ]] \
  || { echo "unexpected PG version" >&2; exit 1; }
echo "connected OK"

echo "==> create ${DB} (idempotent)"
if [[ "$(pg -tAc "SELECT 1 FROM pg_database WHERE datname='${DB}'")" != "1" ]]; then
  sudo -u postgres createdb "${DB}"
fi

echo "==> create todo table (idempotent)"
pg -d "${DB}" <<'SQL'
CREATE TABLE IF NOT EXISTS todo (
  id         bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  title      text        NOT NULL,
  done       boolean     NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now()
);

INSERT INTO todo (title)
SELECT t FROM (VALUES ('buy milk'), ('write script'), ('ship it')) AS v(t)
WHERE NOT EXISTS (SELECT 1 FROM todo);
SQL

echo "==> list tables in ${DB}"
pg -d "${DB}" -c '\dt'

echo "==> records in todo"
pg -d "${DB}" -c 'SELECT * FROM todo ORDER BY id;'
