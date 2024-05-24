FROM php:8.3-apache

# Install necessary PHP extensions
RUN docker-php-ext-install mysqli

# Update package lists, clean up, and remove unnecessary files
RUN apt-get update && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /var/www/html

COPY docker-src-no-banner/ /var/www/html/
