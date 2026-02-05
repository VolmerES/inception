#!/bin/bash
set -euo pipefail

# Secrets
DB_ROOT_PW_FILE="/run/secrets/db_root_password"
DB_USER_PW_FILE="/run/secrets/db_password"

# Required env vars
: "${MYSQL_DATABASE:?MYSQL_DATABASE no definido en .env}"
: "${MYSQL_USER:?MYSQL_USER no definido en .env}"

# Read secrets
DB_ROOT_PASSWORD="$(cat "$DB_ROOT_PW_FILE")"
DB_PASSWORD="$(cat "$DB_USER_PW_FILE")"

# Ensure dirs/permissions
mkdir -p /var/run/mysqld
chown -R mysql:mysql /var/lib/mysql /var/run/mysqld

# Init if first run
# Init if wordpress db doesn't exist (assuming fresh run or apt-installed defaults)
if [ ! -d "/var/lib/mysql/wordpress" ]; then
  
  # Initialize system tables only if missing
  if [ ! -d "/var/lib/mysql/mysql" ]; then
      echo "[mariadb] Inicializando datadir..."
      mariadb-install-db --user=mysql --datadir=/var/lib/mysql >/dev/null
  fi

  echo "[mariadb] Arrancando temporal (socket) para configurar..."
  mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking --socket=/var/run/mysqld/mysqld.sock &
  pid="$!"

  echo "[mariadb] Esperando a que el socket esté listo..."
  for i in {1..30}; do
    if mariadb --protocol=socket -uroot -S /var/run/mysqld/mysqld.sock -e "SELECT 1;" >/dev/null 2>&1; then
      break
    fi
    sleep 1
  done

  echo "[mariadb] Creando DB y usuario..."
  mariadb -vv --protocol=socket -uroot -S /var/run/mysqld/mysqld.sock <<SQL
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
SQL
  sleep 2

  echo "[mariadb] Apagando temporal..."
  mariadb-admin --protocol=socket -uroot -p"${DB_ROOT_PASSWORD}" -S /var/run/mysqld/mysqld.sock shutdown
  wait "$pid" 2>/dev/null || true
fi

echo "[mariadb] Arrancando normal..."
exec mysqld --user=mysql --datadir=/var/lib/mysql --socket=/var/run/mysqld/mysqld.sock --console
