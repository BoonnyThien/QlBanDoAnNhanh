FROM php:8.1-apache

# 1. Cài extensions PHP
RUN docker-php-ext-install pdo pdo_mysql mysqli

# 2. Bật mod_rewrite
RUN a2enmod rewrite

# 3. Cài Composer (cách đúng)
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && php -r "unlink('composer-setup.php');"

# 4. Copy code (sẽ bị override bởi volume)
COPY ../phpCode /var/www/html/

# 5. Set quyền
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80