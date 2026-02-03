#!/bin/bash

# Solo inicializamos si el directorio de datos está vacío
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Inicializando base de datos..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
    
    service mariadb start
    
    # Esperamos a que MariaDB arranque
    sleep 5
    
    mariadb -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};"
    mariadb -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
    mariadb -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';"
    mariadb -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"
    mariadb -e "FLUSH PRIVILEGES;"
    
    # Paramos el servicio para que luego lo levante el contenedor
    mysqladmin -u root -p${MYSQL_ROOT_PASSWORD} shutdown
else
    echo "Base de datos ya inicializada."
fi

exec "$@"

