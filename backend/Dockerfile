FROM php:8.4-cli

WORKDIR /var/www/html

RUN apt-get update && apt-get install -y \
    unzip \
    git \
    curl \
    libzip-dev \
    && docker-php-ext-install zip pdo pdo_mysql

COPY . .

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN composer install --no-dev --optimize-autoloader

# ساخت دیتابیس SQLite
RUN touch database/database.sqlite

# اجرای Migration و Seed
RUN php artisan migrate --seed --force

EXPOSE 10000

CMD php artisan serve --host=0.0.0.0 --port=$PORT