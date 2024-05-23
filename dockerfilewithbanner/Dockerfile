FROM php:8.3-apache

# Install necessary PHP extensions
RUN docker-php-ext-install mysqli 
# pdo pdo_mysql && docker-php-ext-enable pdo_mysql

# Install MySQL client
RUN apt-get update && \
    # apt-get install -y default-mysql-client && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /var/www/html

# Copy source code with additional:
# Promotional banner added to index.php 
# Dark-mode toggle added to index.php 
# A dark-mode.css file added to css folder
COPY abundant-source-banner/ /var/www/html/
