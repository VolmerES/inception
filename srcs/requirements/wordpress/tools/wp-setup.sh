#!/bin/bash
set -e

MYSQL_HOST="${MYSQL_HOST:-mariadb}"

echo "Esperando a MariaDB en ${MYSQL_HOST}..."

# Esperamos a que MariaDB esté listo
until mariadb -h"${MYSQL_HOST}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -e "SELECT 1;" >/dev/null 2>&1; do
  echo "MariaDB no responde aún, reintentando..."
  sleep 2
done

echo "MariaDB está listo. Configurando WordPress..."

cd /var/www/html

if [ ! -f wp-config.php ]; then
  echo "Descargando WordPress..."
  wp core download --allow-root

  echo "Creando wp-config.php..."
  wp config create \
    --allow-root \
    --dbname="${MYSQL_DATABASE}" \
    --dbuser="${MYSQL_USER}" \
    --dbpass="${MYSQL_PASSWORD}" \
    --dbhost="${MYSQL_HOST}"

  echo "Instalando WordPress..."
  wp core install \
    --allow-root \
    --url="${DOMAIN_NAME}" \
    --title="${WP_TITLE}" \
    --admin_user="${WP_ADMIN}" \
    --admin_password="${WP_ADMIN_PASSWORD}" \
    --admin_email="${WP_ADMIN_EMAIL}"

  echo "Creando usuario normal..."
  wp user create \
    --allow-root \
    "${WP_USER}" "${WP_USER_EMAIL}" \
    --user_pass="${WP_USER_PASSWORD}" || true
fi

chown -R www-data:www-data /var/www/html

echo "Arrancando php-fpm..."
exec "$@"

