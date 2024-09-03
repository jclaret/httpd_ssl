# HTTPD SSL with Basic Authentication in Podman

This repository contains instructions and necessary files to create a Podman container running an Apache HTTPD server with SSL enabled and basic authentication on port 8080.

## Prerequisites

- Podman installed on your system
- Basic knowledge of how to use Podman and edit configuration files
- OpenSSL installed for creating SSL certificates

## Setup Instructions

### 1. Create a Working Directory

```bash
mkdir httpd_ssl && cd httpd_ssl
```

### 2. Create a `Dockerfile`

Create a file named `Dockerfile` with the following content:

```Dockerfile
# Use the official httpd base image
FROM httpd:2.4

# Copy the configuration and SSL files
COPY ./httpd.conf /usr/local/apache2/conf/httpd.conf
COPY ./ssl/ /usr/local/apache2/conf/ssl/
COPY ./htpasswd /usr/local/apache2/conf/.htpasswd

# Expose port 8080
EXPOSE 8080
```

### 3. Create the Apache Configuration File

Create a file named `httpd.conf` with the following content:

```apache
ServerRoot "/usr/local/apache2"
Listen 8080

LoadModule authn_core_module modules/mod_authn_core.so
LoadModule auth_basic_module modules/mod_auth_basic.so
LoadModule authn_file_module modules/mod_authn_file.so
LoadModule ssl_module modules/mod_ssl.so
LoadModule socache_shmcb_module modules/mod_socache_shmcb.so
LoadModule mpm_event_module modules/mod_mpm_event.so
LoadModule authz_core_module modules/mod_authz_core.so
LoadModule authz_user_module modules/mod_authz_user.so
LoadModule log_config_module modules/mod_log_config.so
LoadModule unixd_module modules/mod_unixd.so

ServerAdmin you@example.com

# Agrega esta línea
ServerName localhost:8080

SSLCertificateFile "/usr/local/apache2/conf/ssl/server.crt"
SSLCertificateKeyFile "/usr/local/apache2/conf/ssl/server.key"

<VirtualHost *:8080>
    DocumentRoot "/usr/local/apache2/htdocs"
    ServerName localhost:8080

    SSLEngine on

    <Directory "/usr/local/apache2/htdocs">
        AuthType Basic
        AuthName "Restricted Content"
        AuthUserFile "/usr/local/apache2/conf/.htpasswd"
        Require valid-user
    </Directory>

    ErrorLog /usr/local/apache2/logs/error.log
    CustomLog /usr/local/apache2/logs/access.log combined

</VirtualHost>
```

### 4. Create SSL Certificates

Create a directory named `ssl` and generate the SSL certificate:

```bash
mkdir ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ssl/server.key -out ssl/server.crt -subj "/C=US/ST=State/L=City/O=Organization/OU=Unit/CN=localhost"
```

### 5. Create the `.htpasswd` File

Create a `.htpasswd` file for basic authentication:

```bash
htpasswd -cb htpasswd username password
```

Replace `username` and `password` with your desired credentials.

### 6. Build the Podman Image

Build the image using the following command:

```bash
podman build -t httpd-ssl-auth .
```

### 7. Run the Container

Run the container using:

```bash
podman run -d -p 8080:8080 --name my-httpd-secure httpd-ssl-auth
podman run -d -p 8080:8080 --name my-httpd-secure -v /opt/webcache/data:/usr/local/apache2/htdocs httpd-ssl-auth
```

### 8. Access the Server

You can access the server using:

```
https://localhost:8080
```

You'll be prompted for the username and password you configured.

## Troubleshooting

- If the container does not start, check the logs using:

```bash
podman logs <container_id>
```

- Ensure all required modules are loaded and all paths in the `httpd.conf` file are correct.

## License

This project is licensed under the MIT License.

