# Sử dụng image PHP 8.1 với Apache
FROM php:8.1-apache

# 1. Cài đặt các dependencies cần thiết
RUN apt-get update && apt-get install -y \
    libonig-dev \
    libzip-dev \
    zip \
    unzip \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# 2. Cài extensions PHP
RUN docker-php-ext-install pdo pdo_mysql mysqli mbstring zip

# 3. Bật mod_rewrite và mod_headers
RUN a2enmod rewrite headers

# 4. Copy cấu hình Apache
COPY ./config/apache.conf /etc/apache2/sites-available/000-default.conf
RUN a2ensite 000-default

# 5. Cấu hình Apache để cho phép symbolic links và thêm ServerName
RUN sed -i 's/Options Indexes FollowSymLinks/Options Indexes FollowSymLinks SymLinksIfOwnerMatch/' /etc/apache2/apache2.conf \
    && echo "ServerName localhost" >> /etc/apache2/apache2.conf

# 6. Tạo thư mục cho ứng dụng
WORKDIR /var/www/html

# 7. Copy source code
COPY phpCode/ .

# 8. Cấu hình quyền truy cập
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# 9. Cấu hình PHP cho encoding
RUN echo "[mbstring]" > /usr/local/etc/php/conf.d/docker-php-ext-mbstring.ini \
    && echo "default_charset = UTF-8" >> /usr/local/etc/php/conf.d/docker-php-ext-mbstring.ini \
    && echo "mbstring.internal_encoding = UTF-8" >> /usr/local/etc/php/conf.d/docker-php-ext-mbstring.ini \
    && echo "mbstring.http_input = UTF-8" >> /usr/local/etc/php/conf.d/docker-php-ext-mbstring.ini \
    && echo "mbstring.http_output = UTF-8" >> /usr/local/etc/php/conf.d/docker-php-ext-mbstring.ini

# 10. Kiểm tra sự tồn tại của các file quan trọng
RUN test -f /var/www/html/index.php || (echo "ERROR: index.php not found in /var/www/html" && exit 1) \
    && test -d /var/www/html/database || (echo "ERROR: database directory not found in /var/www/html" && exit 1) \
    && test -f /var/www/html/database/qlbandoannhanh.sql || (echo "ERROR: qlbandoannhanh.sql not found in /var/www/html/database" && exit 1)

# 11.Copy cấu hình charset
COPY utf8.cnf /etc/mysql/conf.d/utf8.cnf

EXPOSE 80

CMD ["apache2-foreground"]