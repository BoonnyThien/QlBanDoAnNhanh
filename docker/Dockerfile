FROM php:8.1-apache

# 1. Cài đặt các dependencies cần thiết
RUN apt-get update && apt-get install -y \
    libonig-dev \
    libzip-dev \
    zip \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# 2. Cài extensions PHP
RUN docker-php-ext-install pdo pdo_mysql mysqli mbstring zip

# 3. Bật mod_rewrite và mod_headers
RUN a2enmod rewrite headers

# 4. Cài Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && php -r "unlink('composer-setup.php');"

# 5. Copy cấu hình Apache
COPY docker/apache.conf /etc/apache2/sites-available/000-default.conf
RUN a2ensite 000-default

# 6. Cấu hình Apache để cho phép symbolic links
RUN sed -i 's/Options Indexes FollowSymLinks/Options Indexes FollowSymLinks SymLinksIfOwnerMatch/' /etc/apache2/apache2.conf

# 7. Tạo thư mục cho ứng dụng
WORKDIR /var/www/html

# 8. Copy composer.json trước
COPY composer.json .

# 9. Cài đặt dependencies
RUN composer install --no-dev --optimize-autoloader

# 10. Copy source code
COPY phpCode/ .

# 11. Cấu hình quyền truy cập
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

EXPOSE 80

CMD ["apache2-foreground"]