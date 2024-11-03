# Base image Debian
FROM debian:latest

# Variables d'environnement pour MariaDB
ENV MYSQL_ROOT_PASSWORD=rootpassword
ENV MYSQL_DATABASE=laravel_db
ENV MYSQL_USER=laraveluser
ENV MYSQL_PASSWORD=laravelpassword

# Variables d'environnement pour InfluxDB
ENV INFLUXDB_DB=influxdb
ENV INFLUXDB_ADMIN_USER=admin
ENV INFLUXDB_ADMIN_PASSWORD=adminadmin

# Mise à jour et installation des dépendances
RUN apt-get update && apt-get install -y \
    php \
    php-cli \
    php-mbstring \
    php-xml \
    php-mysql \
    php-curl \
    php-zip \
    php-gd \
    nodejs \
    npm \
    mariadb-server \
    python3 \
    python3-pip \
    curl \
    git \
    unzip \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && curl -sL https://repos.influxdata.com/influxdb.key | apt-key add - \
    && echo "deb https://repos.influxdata.com/debian stable main" | tee /etc/apt/sources.list.d/influxdb.list \
    && apt-get update && apt-get install -y influxdb

# Copie du projet Laravel dans le répertoire /app
COPY ./laravel-project /app

# Déplacement dans le répertoire du projet
WORKDIR /app

# Installation des dépendances Laravel
RUN npm install && composer install

# Démarrage des services MariaDB et InfluxDB, et initialisation des bases de données
RUN service mariadb start \
    && service influxdb start \
    && mysql -u root -p$MYSQL_ROOT_PASSWORD -e "CREATE DATABASE $MYSQL_DATABASE;" \
    && mysql -u root -p$MYSQL_ROOT_PASSWORD -e "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';" \
    && mysql -u root -p$MYSQL_ROOT_PASSWORD -e "GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';" \
    && influx -execute "CREATE DATABASE $INFLUXDB_DB" \
    && influx -execute "CREATE USER $INFLUXDB_ADMIN_USER WITH PASSWORD '$INFLUXDB_ADMIN_PASSWORD' WITH ALL PRIVILEGES"

# Exposition des ports pour MariaDB, InfluxDB et l'application Laravel
EXPOSE 3306 8086 8000

# Démarrage de Laravel et services
CMD service mariadb start && service influxdb start && php artisan migrate && php artisan serve --host=0.0.0.0 --port=8000
