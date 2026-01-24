# syntax=docker/dockerfile:1

# Use the latest version of the Amazon Linux base image
FROM amazonlinux:2023

# Avoid interactive prompts (if any)
ENV TERM=xterm \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

# ================================================================
# Set the build argument directive
# ================================================================

# Set the build argument directive
ARG PROJECT_NAME
ARG ENVIRONMENT
ARG RECORD_NAME
ARG DOMAIN_NAME
ARG GITHUB_USERNAME
ARG REPOSITORY_NAME
ARG SERVICE_PROVIDER_FILE_NAME
ARG APPLICATION_CODE_FILE_NAME
ARG RDS_ENDPOINT
ARG RDS_DB_NAME
ARG RDS_DB_USERNAME

# ================================================================
# Define environment variables
# ================================================================

# Use the build argument to set environment variables
ENV PROJECT_NAME=$PROJECT_NAME
ENV ENVIRONMENT=$ENVIRONMENT
ENV RECORD_NAME=$RECORD_NAME
ENV DOMAIN_NAME=$DOMAIN_NAME
ENV GITHUB_USERNAME=$GITHUB_USERNAME
ENV REPOSITORY_NAME=$REPOSITORY_NAME
ENV SERVICE_PROVIDER_FILE_NAME=$SERVICE_PROVIDER_FILE_NAME
ENV APPLICATION_CODE_FILE_NAME=$APPLICATION_CODE_FILE_NAME
ENV RDS_ENDPOINT=$RDS_ENDPOINT
ENV RDS_DB_NAME=$RDS_DB_NAME
ENV RDS_DB_USERNAME=$RDS_DB_USERNAME

# ================================================================
# Install server dependencies
# ================================================================

# Update all packages
RUN yum update -y

# Install git and unzip
RUN dnf install -y git unzip

# Install Git LFS
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.rpm.sh | bash \
    && dnf install -y git-lfs \
    && git lfs install

# Install Apache, PHP and required extensions
RUN dnf install -y httpd php php-cli php-fpm php-mysqlnd php-bcmath php-ctype php-fileinfo php-json php-mbstring php-openssl php-pdo php-gd php-tokenizer php-xml php-curl

# Update memory_limit and max_execution_time in php.ini
RUN sed -i '/^memory_limit =/ s/=.*$/= 256M/' /etc/php.ini \
    && sed -i '/^max_execution_time =/ s/=.*$/= 300/' /etc/php.ini

# Enable mod_rewrite in Apache for .htaccess support
RUN sed -i '/<Directory "\/var\/www\/html">/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf

# ================================================================
# Upload application code to container
# ================================================================

# Navigate to web directory
WORKDIR /var/www/html

# Clone the GitHub repository using BuildKit secret (this gets the LFS pointer files)
RUN --mount=type=secret,id=personal_access_token \
    PERSONAL_ACCESS_TOKEN=$(cat /run/secrets/personal_access_token) && \
    git clone https://${PERSONAL_ACCESS_TOKEN}@github.com/${GITHUB_USERNAME}/${REPOSITORY_NAME}.git .

# Pull the actual LFS files
RUN git lfs pull

# Unzip the app code
RUN unzip ${APPLICATION_CODE_FILE_NAME}.zip

# Copy all files from 'nest' to web root
RUN cp -R ${APPLICATION_CODE_FILE_NAME}/. /var/www/html/

# Remove the 'nest' directory and zip file
RUN rm -rf ${APPLICATION_CODE_FILE_NAME} ${APPLICATION_CODE_FILE_NAME}.zip

# ================================================================
# Set permissions for directories
# ================================================================

# Set permissions for web and storage directories
RUN chmod -R 777 /var/www/html \
    && chmod -R 777 /var/www/html/bootstrap/cache/ \
    && chmod -R 777 /var/www/html/storage/

# ================================================================
# Update the .env file
# ================================================================

# Update .env variables using BuildKit secret for password
RUN --mount=type=secret,id=rds_db_password \
    RDS_DB_PASSWORD=$(cat /run/secrets/rds_db_password) && \
    sed -i "/^APP_NAME=/ s|=.*$|=${PROJECT_NAME}-${ENVIRONMENT}|" .env && \
    sed -i "/^APP_URL=/ s|=.*$|=https://${RECORD_NAME}.${DOMAIN_NAME}/|" .env && \
    sed -i "/^DB_HOST=/ s|=.*$|=${RDS_ENDPOINT}|" .env && \
    sed -i "/^DB_DATABASE=/ s|=.*$|=${RDS_DB_NAME}|" .env && \
    sed -i "/^DB_USERNAME=/ s|=.*$|=${RDS_DB_USERNAME}|" .env && \
    sed -i "/^DB_PASSWORD=/ s|=.*$|=${RDS_DB_PASSWORD}|" .env

# ================================================================
# Replace the AppServiceProvider.php file
# ================================================================

# Replace AppServiceProvider.php
COPY ${SERVICE_PROVIDER_FILE_NAME}.php app/Providers/AppServiceProvider.php

# ================================================================
# Configure locales, container startup, and expose ports
# ================================================================

# Expose the default Apache and MySQL ports
EXPOSE 80 3306

# Install and configure locales for Amazon Linux 2023
RUN dnf install -y glibc-langpack-en && \
    dnf clean all

# Set locale environment variables
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Copy the start-services script into the container
COPY start-services.sh /usr/local/bin/start-services.sh

# Ensure the script is executable and fix any line ending issues
RUN chmod +x /usr/local/bin/start-services.sh && \
    sed -i 's/\r$//' /usr/local/bin/start-services.sh

# Run the script to start both PHP-FPM and Apache
CMD ["/usr/local/bin/start-services.sh"]