# Usar la imagen base de httpd
FROM httpd:2.4

# Copiar los archivos de configuración y certificados SSL
COPY ./httpd.conf /usr/local/apache2/conf/httpd.conf
COPY ./ssl/ /usr/local/apache2/conf/ssl/
COPY ./htpasswd /usr/local/apache2/conf/.htpasswd

# Exponer el puerto 8080
EXPOSE 8080
