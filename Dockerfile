FROM php:8.3-apache

# Install necessary PHP extensions
RUN docker-php-ext-install mysqli

# Update package lists, clean up, and remove unnecessary files
RUN apt-get update && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /var/www/html

# Copy source code with additional:
## - Promotional banner added to index.php 
## - Dark-mode toggle added to index.php 
## - A dark-mode.css file added to css folder
COPY abundant-source/ /var/www/html/
