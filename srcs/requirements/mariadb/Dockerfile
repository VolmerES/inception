#OS Base
FROM debian:bookworm-slim

#Evitar prompts interactivos durante la instalación
ENV DEBIAN_FRONTEND=noninteractive

#Instalar MariaDB server, utilidades y certificados
RUN apt-get update && apt-get install -y --no-install-recommends \
bash \
mariadb-server \
mariadb-client \
ca-certificates \
&& rm -rf /var/lib/apt/lists/*

#Copiamos configuración MariaDB
COPY conf/my.conf /etc/mysql/mariadb.conf.d/50-server.cnf

#Copiamos scripts de arranque para la primera vez
COPY tools/init_db.sh /usr/local/bin/init_db.sh

#Permisos de ejecución de script
RUN chmod +x /usr/local/bin/init_db.sh

#Puerto interno del servicio (red inception virtual interna)
EXPOSE 3306

#PID 1 ENTRYPOINT ejecuta el proceso final sin loops
ENTRYPOINT ["/usr/local/bin/init_db.sh"]
