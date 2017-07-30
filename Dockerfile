FROM php:5.6-apache

RUN apt-get update 

RUN apt-get install -y \
	git \
	libbz2-dev \
	zlib1g-dev \
	libxml2-dev \
	libgd-dev \
	libpng12-dev \
	libjpeg62-turbo-dev \ 
	libfreetype6-dev \
	mysql-client \
&&  apt-get clean \
&&  rm -rf /var/lib/apt/lists/*

COPY php.ini /usr/local/etc/php/ 

RUN pear config-set php_ini /usr/local/etc/php/php.ini

RUN docker-php-ext-install mysql mysqli pdo pdo_mysql zip iconv gd
RUN yes | pecl install xdebug

# enable mod_rewrite
RUN a2enmod rewrite

# Install Composer.
RUN cd /tmp/ && curl -sS https://getcomposer.org/installer | php \
&&  mv /tmp/composer.phar /usr/local/bin/composer

# Install Drush 8.
RUN composer global require drush/drush:8.* \
&&  composer global update \
&&  ln -s /root/.composer/vendor/bin/drush /usr/local/bin/drush

# Build Drupal site.
COPY .git/modules/gpii.net/ /tmp/gpii.net.git
RUN rm -rf /var/www/* && cd /var/www/ && git clone /tmp/gpii.net.git . 

RUN git -C /var/www submodule update --init --recursive

RUN chown -R www-data:www-data /var/www
RUN ln -s web /var/www/html
RUN ln -s developerspace.gpii.net /var/www/html/sites/default


RUN mkdir -p ~/.drush/ && drush --root=/var/www/html/web site-alias @self --full --with-optional | sed -e '1i\\<?php' -e '$a\\?>' -e s/"self"/"default"/ >>~/.drush/default.alias.drushrc.php

COPY devspace-makefile/devspace-db-sanitized.sql.gz /tmp

ADD entrypoint.sh entrypoint.sh
ADD wait-for-it/wait-for-it.sh wait-for-it.sh 

RUN chmod +x wait-for-it.sh entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]

CMD ["apache2-foreground"]
