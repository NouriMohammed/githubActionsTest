FROM php:8.2-apache

RUN mkdir -p /var/www/html/symfony-ci-test-app
COPY . /var/www/html/symfony-ci-test-app
WORKDIR /var/www/html/symfony-ci-test-app
RUN cp symfony-apache.conf /etc/apache2/sites-available/
RUN apt-get -y update

#installer les pré-requis pour symfony
RUN apt-get install -y libzip-dev zip && docker-php-ext-install zip
RUN apt-get install -y libicu-dev && docker-php-ext-configure intl && docker-php-ext-install -j$(nproc) intl
RUN sed -i 's/;extension=sqlite3/extension=sqlite3/g' /usr/local/etc/php/php.ini-development
RUN sed -i 's/;extension=intl/extension=intl/g' /usr/local/etc/php/php.ini-development
RUN sed -i 's/;extension=sqlite3/extension=sqlite3/g' /usr/local/etc/php/php.ini-production
RUN sed -i 's/;extension=intl/extension=intl/g' /usr/local/etc/php/php.ini-production

#composer
#RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
#RUN php -r "if (hash_file('sha384', 'composer-setup.php') === '48e3236262b34d30969dca3c37281b3b4bbe3221bda826ac6a9a62d6444cdb0dcd0615698a5cbe587c3f0fe57a54d8f5') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
#RUN php composer-setup.php
#RUN php -r "unlink('composer-setup.php');"
#RUN cp composer.phar /usr/local/bin/composer
RUN curl -s https://getcomposer.org/installer | php
RUN cp composer.phar /usr/local/bin/composer


#configurer la Vhost
RUN a2ensite symfony-apache.conf
RUN a2enmod rewrite

#installer dependances
#RUN /usr/local/bin/composer require symfony/flex
RUN php -d memory_limit=-1 /usr/local/bin/composer install
#RUN php /usr/local/bin/composer require symfony/apache-pack
RUN chown -R :www-data /var/www/html/symfony-ci-test-app
RUN chmod -R 775 /var/www/html/symfony-ci-test-app

