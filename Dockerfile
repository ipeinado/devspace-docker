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

#Custom php.ini
COPY php.ini /usr/local/etc/php/ 
RUN pear config-set php_ini /usr/local/etc/php/php.ini

#extensions mainly database and debug
RUN docker-php-ext-install mysql mysqli pdo pdo_mysql zip iconv gd
RUN yes | pecl install xdebug

# enable mod_rewrite
RUN a2enmod rewrite

# Install Composer.
RUN cd /tmp/ && curl -sS https://getcomposer.org/installer | php \
&&  mv /tmp/composer.phar /usr/local/bin/composer

#Set global composer dir and add to path
RUN mkdir /usr/local/lib/composer && chmod 755 /usr/local/lib/composer
ENV COMPOSER_HOME=/usr/local/lib/composer
ENV PATH="${COMPOSER_HOME}/vendor/bin:${PATH}"

# Install Drush 8.
RUN composer global require drush/drush:8.* \
&&  composer global update \
&&  chmod 755 ${COMPOSER_HOME}/vendor/bin/drush 

# Build Drupal site.
RUN chown -R www-data:www-data /var/www

# share local gpii.net copy (make it bare)
COPY .git/modules/gpii.net/ /tmp/gpii.net.git
RUN sed -i '/^\s*worktree/d' /tmp/gpii.net.git/config 
RUN git -C /tmp/gpii.net.git config --bool core.bare true 

# do everything as www-data to get correct permissions 
USER www-data:www-data 
RUN cd /var/www && git init && git fetch /tmp/gpii.net.git  && git checkout FETCH_HEAD 

#init submodules
RUN git -C /var/www submodule update --init --recursive

#replace default dir with symlink
RUN rm -r /var/www/html && ln -s web /var/www/html
RUN ln -s developerspace.gpii.net /var/www/html/sites/default

#configure alias "@default" for www-data drush
RUN mkdir -p ~/.drush/ && drush --root=/var/www/html site-alias @self --full --with-optional | sed -e '1i\\<?php' -e '$a\\?>' -e s/"self"/"default"/ >>~/.drush/default.alias.drushrc.php

#Copy Data
COPY devspace-makefile/devspace-db-sanitized.sql.gz /tmp

#Startup scripts
ADD entrypoint.sh /entrypoint.sh
ADD wait-for-it/wait-for-it.sh /wait-for-it.sh 

#Switch to root for chmod and apache start 
USER root 
RUN chmod 755 /wait-for-it.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["apache2-foreground"]
