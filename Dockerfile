FROM yiisoftware/yii2-php:7.4-apache

# Set working directory
WORKDIR /app

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    zip \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy composer files and install dependencies
COPY composer.json ./
RUN composer install --prefer-dist --no-scripts --no-dev --no-autoloader

# Copy application files
COPY . .

# Run composer scripts and generate autoloader
RUN composer dump-autoload --no-scripts --no-dev --optimize

# Set permissions
RUN chown -R www-data:www-data /app \
    && chmod -R 755 /app/web/assets \
    && chmod -R 755 /app/runtime

# Configure Apache
RUN a2enmod rewrite

# Create a proper config file for the database connection
RUN echo '<?php return ["class" => "yii\db\Connection", "dsn" => "mysql:host=db;dbname=yii2basic", "username" => "yii2user", "password" => "password", "charset" => "utf8"];' > /app/config/db.php

# Create a basic server name configuration
RUN echo 'ServerName localhost' >> /etc/apache2/apache2.conf

EXPOSE 80

CMD ["apache2-foreground"]
