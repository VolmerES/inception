FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
bash \
nginx \
openssl \
ca-certificates \
gettext-base \
&& rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/ssl \
             /etc/nginx/templates
#Carpeta donde guardamos certificado y  key

COPY conf/nginx.conf /etc/nginx/templates/nginx.conf
#Copiamos un template porque nginx no interpreta variables de entorno

COPY tools/generate_ssl.sh /usr/local/bin/entrypoint.sh
#Script que gener cer si falta + crea nginx.conf +  arranca NGINX

RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 443
#Puerto HTTPS

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
#Proceso incial de contenedor (PID1)
