FROM debian:buster

MAINTAINER Fernando Jimenez Cuerva

RUN apt update && \
	apt install -y nginx \
	openssl \
	mariadb-server \
	php-fpm \
	php-mysql \
	php-mbstring \
	wget

#Copia srcs

COPY	srcs/index_hola.html /var/www/html/
COPY 	srcs/ferfox /etc/nginx/sites-available/
COPY	srcs/wordpress /var/www/html/wordpress
COPY	srcs/config.inc.php /tmp/
COPY	srcs/init.sql	/tmp/
COPY	srcs/wordpress.sql /tmp/

#Instala NGINX

RUN rm -rf /etc/nginx/sites-available/default && \
	rm -rf /etc/nginx/sites-enabled/default && \
	ln -sf /etc/nginx/sites-available/ferfox /etc/nginx/sites-enabled/ && \
	chown -R www-data:www-data /var/www/* && \
	chmod -R 755 /var/www/*

#Instala BSD

RUN	service mysql start && \
	mysql -u root --password= < /tmp/init.sql && \
	mysql wordpress -u root --password= < /tmp/wordpress.sql

#Instala SSL

RUN chmod 700 /etc/ssl/private && \
	openssl req -x509 -nodes -days 365 \
	-newkey rsa:2048 -subj "/C=SP/ST=Spain/L=Madrid/O=42/CN=127.0.0.1" \
	-keyout /etc/ssl/private/ferfox.key \
	-out /etc/ssl/certs/ferfox.crt && \
	openssl dhparam -out /etc/nginx/dhparam.pem 1000

#Instala PHPMYADMIN

RUN wget https://files.phpmyadmin.net/phpMyAdmin/4.9.0.1/phpMyAdmin-4.9.0.1-english.tar.gz && \
	mkdir /var/www/html/phpmyadmin && \
	tar xzf phpMyAdmin-4.9.0.1-english.tar.gz --strip-components=1 -C /var/www/html/phpmyadmin && \
	cp /tmp/config.inc.php /var/www/html/phpmyadmin/ 

EXPOSE 80 443

CMD service nginx start && \
	service mysql start && \
	service php7.3-fpm start && \
	bash
