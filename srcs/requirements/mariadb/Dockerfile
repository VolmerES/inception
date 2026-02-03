FROM debian:bookworm

RUN apt update && apt install -y mariadb-server && rm -rf /var/lib/apt/lists/*

COPY ./conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

COPY ./tools/50-config.sh /tmp/50-config.sh
RUN chmod +x /tmp/50-config.sh

ENTRYPOINT ["bash", "/tmp/50-config.sh"]

CMD ["mysqld_safe"]

