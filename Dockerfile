# Use the official PHP + Apache base image
FROM php:8.2-apache

# Maintainer info
LABEL maintainer="hello@kesaralive.com"
LABEL description="Apache / PHP 8.2 development environment"

# Avoid interactive shell prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=xterm

# Update system and install dependencies
RUN apt-get update && apt-get install -y \
    locales \
    nano \
    unzip \
    git \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libxml2-dev \
    zip \
 && docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-install -j$(nproc) gd pdo pdo_mysql mysqli zip xml bcmath mbstring \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Generate locales
RUN locale-gen en_US.UTF-8 fr_FR.UTF-8 de_DE.UTF-8

# Enable Apache modules
RUN a2enmod rewrite headers

# Configure PHP for development
RUN echo "error_reporting = E_ALL" > /usr/local/etc/php/conf.d/error_reporting.ini && \
    echo "display_errors = On" >> /usr/local/etc/php/conf.d/error_reporting.ini && \
    echo "zlib.output_compression = Off" >> /usr/local/etc/php/conf.d/error_reporting.ini

# Fix Apache ServerName warning
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Allow .htaccess overrides for mod_rewrite support
RUN sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' \
    /etc/apache2/apache2.conf

# Set correct permissions for /var/www
RUN chgrp -R www-data /var/www && \
    find /var/www -type d -exec chmod 775 {} \; && \
    find /var/www -type f -exec chmod 664 {} \;

# Copy your source code into the image
# COPY ./src/ /var/www/html/

# Expose HTTP port
EXPOSE 80

# Start Apache in the foreground
CMD ["apache2-foreground"]
