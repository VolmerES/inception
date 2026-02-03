FROM debian:bookworm

# -------------------------------------------------------
# 1. Instalar PHP + extensiones necesarias + cliente MariaDB
# -------------------------------------------------------
RUN apt update && apt install -y \
    php-fpm php-mysql php-mysqli php-cli php-mbstring php-xml php-curl \
    curl mariadb-client less vim \
 && rm -rf /var/lib/apt/lists/*

# -------------------------------------------------------
# 2. Configurar PHP-FPM para escuchar en 9000 (para NGINX)
# -------------------------------------------------------
RUN sed -i "s|listen = .*|listen = 0.0.0.0:9000|" /etc/php/*/fpm/pool.d/www.conf

WORKDIR /var/www/html

# -------------------------------------------------------
# 3. Instalar WP-CLI
# -------------------------------------------------------
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
 && php wp-cli.phar --info \
 && chmod +x wp-cli.phar \
 && mv wp-cli.phar /usr/local/bin/wp \
 && rm -f wp-cli.phar

# -------------------------------------------------------
# 4. Copiar script de arranque
# -------------------------------------------------------
COPY ./tools/wp-setup.sh /usr/local/bin/wp-setup.sh
RUN chmod +x /usr/local/bin/wp-setup.sh

ENTRYPOINT ["/usr/local/bin/wp-setup.sh"]

# -------------------------------------------------------
# 5. Arrancar php-fpm correctamente (Debian 12 usa php-fpm8.2)
# -------------------------------------------------------
CMD ["/usr/sbin/php-fpm8.2", "-F"]

