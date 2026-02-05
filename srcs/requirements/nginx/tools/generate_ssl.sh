#!/bin/sh
set -eu

SSL_DIR="/etc/nginx/ssl"
CERT="${SSL_DIR}/cert.pem"
KEY="${SSL_DIR}/key.pem"

TEMPLATE="/etc/nginx/templates/nginx.conf"
OUTCONF="/etc/nginx/nginx.conf"

mkdir -p "${SSL_DIR}"

# Generar certificado si falta
if [ ! -f "${CERT}" ] || [ ! -f "${KEY}" ]; then
  echo "[nginx] Generating SSL cert..."
  openssl req -x509 -nodes -newkey rsa:2048 \
    -keyout "${KEY}" \
    -out "${CERT}" \
    -days 365 \
    -subj "/C=ES/ST=Madrid/L=Madrid/O=42/OU=Inception/CN=${DOMAIN_NAME}"

  chmod 600 "${KEY}"
  chmod 644 "${CERT}"
  echo "[nginx] SSL cert generated: ${CERT}"
else
  echo "[nginx] SSL cert already exists. Skipping generation."
fi

# Renderizar nginx.conf desde template (sustituye ${DOMAIN_NAME})
if [ -f "${TEMPLATE}" ]; then
  echo "[nginx] Rendering nginx.conf from template..."
  envsubst '${DOMAIN_NAME}' < "${TEMPLATE}" > "${OUTCONF}"
else
  echo "[nginx] ERROR: Template not found: ${TEMPLATE}"
  exit 1
fi

# Validar config antes de arrancar
nginx -t

# Arrancar nginx en primer plano como PID 1
exec nginx -g 'daemon off;'
