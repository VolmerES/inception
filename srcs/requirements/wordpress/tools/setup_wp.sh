#!/bin/bash
# Indica que el script se ejecuta con bash

set -e
# Si cualquier comando falla, el script termina (evita estados corruptos)

DB_PASSWORD="$(cat /run/secrets/db_password)"
# Lee la contraseña de MariaDB desde Docker secrets

WP_ADMIN_PASSWORD="$(cat /run/secrets/wp_admin_password)"
# Lee la contraseña del admin WordPress desde secrets

WP_USER_PASSWORD="$(cat /run/secrets/wp_user_password)"
# Lee la contraseña del segundo usuario WordPress

: "${MYSQL_DATABASE:?}"
# Verifica que MYSQL_DATABASE exista o aborta

: "${MYSQL_USER:?}"
# Verifica que MYSQL_USER exista o aborta

: "${WP_TITLE:?}"
# Verifica que el título de WordPress exista

: "${WP_ADMIN_USER:?}"
# Verifica que el usuario admin exista

: "${WP_ADMIN_EMAIL:?}"
# Verifica que el email admin exista

: "${WP_USER:?}"
# Verifica que el segundo usuario exista

: "${WP_USER_EMAIL:?}"
# Verifica que el email del segundo usuario exista

echo "[wordpress] Esperando a MariaDB..."
# Mensaje informativo

for i in {1..30}; do
# Bucle limitado (NO infinito) para esperar a MariaDB
  if php -r "new mysqli('mariadb', '$MYSQL_USER', '$DB_PASSWORD', '$MYSQL_DATABASE');" \
     >/dev/null 2>&1; then
    break
    # Sale del bucle si la conexión funciona
  fi
  sleep 1
  # Espera 1 segundo entre intentos
done

if [ ! -f wp-config.php ]; then
# Solo instala WordPress si no existe (volumen vacío)

  echo "[wordpress] Descargando WordPress..."
  # Mensaje informativo

  curl -s https://wordpress.org/latest.tar.gz | tar xz --strip 1
  # Descarga WordPress y lo extrae en /var/www/html

  echo "[wordpress] Configurando wp-config.php..."

  cp wp-config-sample.php wp-config.php
  # Crea el archivo de configuración principal

  sed -i "s/database_name_here/$MYSQL_DATABASE/" wp-config.php
  # Sustituye el nombre de la base de datos

  sed -i "s/username_here/$MYSQL_USER/" wp-config.php
  # Sustituye el usuario de la base de datos

  sed -i "s/password_here/$DB_PASSWORD/" wp-config.php
  # Sustituye la contraseña de la base de datos

  sed -i "s/localhost/mariadb/" wp-config.php

  echo "[wordpress] Descargando WP-CLI..."
  curl -s -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
  chmod +x wp-cli.phar

  echo "[wordpress] Instalando WordPress..."

  php wp-cli.phar core install \
    --url="$DOMAIN_NAME" \
    --title="$WP_TITLE" \
    --admin_user="$WP_ADMIN_USER" \
    --admin_password="$WP_ADMIN_PASSWORD" \
    --admin_email="$WP_ADMIN_EMAIL" \
    --skip-email \
    --allow-root

  php wp-cli.phar user create \
    "$WP_USER" "$WP_USER_EMAIL" \
    --user_pass="$WP_USER_PASSWORD" \
    --allow-root || true
  # Crea el segundo usuario (si ya existe, no falla)
fi

chown -R www-data:www-data /var/www/html
# Ajusta permisos de archivos WordPress

echo "[wordpress] Arrancando PHP-FPM..."
# Mensaje informativo

exec php-fpm8.2 -F
# Arranca PHP-FPM en primer plano (PID 1, sin loops)

