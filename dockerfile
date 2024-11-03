# Base image with PHP and Composer
FROM php:8.0-fpm

# Installation des extensions PHP et dépendances système
RUN apt-get update && apt-get install -y \
    php-mbstring php-xml php-mysql php-curl php-zip php-gd \
    nodejs npm git unzip \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copie des fichiers de l'application Laravel
WORKDIR /app
COPY ./laravel-project /app

# Installation des dépendances Laravel
RUN npm install && composer install

# Exposition du port Laravel
EXPOSE 8000

# Commande pour démarrer Laravel
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
