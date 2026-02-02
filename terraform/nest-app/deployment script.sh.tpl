#!/bin/bash

# ================================================================
# Install server dependencies
# ================================================================

# Update all packages
sudo yum update -y

# Install Apache, PHP 8 and required extensions
sudo dnf install -y httpd php php-cli php-fpm php-mysqlnd php-bcmath php-ctype php-fileinfo php-json php-mbstring php-openssl php-pdo php-gd php-tokenizer php-xml php-curl

# Update PHP settings for memory and execution time
sudo sed -i '/^memory_limit =/ s/=.*$/= 256M/' /etc/php.ini
sudo sed -i '/^max_execution_time =/ s/=.*$/= 300/' /etc/php.ini

# Enable mod_rewrite in Apache for .htaccess support
sudo sed -i '/<Directory "\/var\/www\/html">/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf

# ================================================================
# Upload application code to EC2
# ================================================================

# Download the app zip file from S3
sudo aws s3 cp ${WEB_FILES_S3_URI} /var/www/html

# Navigate to web directory
cd /var/www/html

# Unzip the app code
sudo unzip ${APPLICATION_CODE_FILE_NAME}.zip

# Copy all files from 'nest' to web root
sudo cp -R ${APPLICATION_CODE_FILE_NAME}/. /var/www/html/

# Remove the 'nest' directory and zip file
sudo rm -rf ${APPLICATION_CODE_FILE_NAME} ${APPLICATION_CODE_FILE_NAME}.zip

# ================================================================
# Set permissions for directories
# ================================================================

# Set permissions for web and storage directories
sudo chmod -R 777 /var/www/html
sudo chmod -R 777 /var/www/html/bootstrap/cache/
sudo chmod -R 777 /var/www/html/storage/

# ================================================================
# Update the .env file
# ================================================================

# Update .env variables
sudo sed -i "/^APP_NAME=/ s|=.*$|=${PROJECT_NAME}-${ENVIRONMENT}|" .env
sudo sed -i "/^APP_URL=/ s|=.*$|=https://${RECORD_NAME}.${DOMAIN_NAME}/|" .env
sudo sed -i "/^DB_HOST=/ s|=.*$|=${RDS_ENDPOINT}|" .env
sudo sed -i "/^DB_DATABASE=/ s|=.*$|=${RDS_DB_NAME}|" .env
sudo sed -i "/^DB_USERNAME=/ s|=.*$|=${RDS_DB_USERNAME}|" .env
sudo sed -i "/^DB_PASSWORD=/ s|=.*$|=${RDS_DB_PASSWORD}|" .env

# ================================================================
# verify .env contents
# ================================================================

cat .env

# ================================================================
# Replace the AppServiceProvider.php file
# ================================================================

# Replace AppServiceProvider.php
sudo aws s3 cp ${SERVICE_PROVIDER_FILE_S3_URI} /var/www/html/app/Providers/AppServiceProvider.php

# ================================================================
# Start and enable Apache to run on boot
# ================================================================

# Enable Apache to start automatically on boot
sudo systemctl enable httpd

# Start Apache service
sudo systemctl start httpd

# Verify Apache is running
sudo systemctl status httpd
