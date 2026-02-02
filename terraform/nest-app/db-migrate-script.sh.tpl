#!/bin/bash

# ================================================================
# Install Flyway and run database migrations
# ================================================================

# Update all packages
sudo yum update -y

# Navigate to a consistent directory
cd /home/ec2-user

# Download and extract Flyway
sudo wget -qO- https://download.red-gate.com/maven/release/com/redgate/flyway/flyway-commandline/${FLYWAY_VERSION}/flyway-commandline-${FLYWAY_VERSION}-linux-x64.tar.gz | tar -xvz && sudo ln -s $(pwd)/flyway-${FLYWAY_VERSION}/flyway /usr/local/bin

# Create the SQL directory for migrations (as stated in the flywheel documentation)
sudo mkdir -p sql

# Download the migration SQL script from AWS S3
sudo aws s3 cp ${SQL_SCRIPT_S3_URI} sql/

# Run Flyway migration
sudo flyway -url=jdbc:mysql://${RDS_ENDPOINT}:3306/${RDS_DB_NAME}?allowPublicKeyRetrieval=true \
  -user=${RDS_DB_USERNAME} \
  -password="${RDS_DB_PASSWORD}" \
  -locations=filesystem:sql \
  migrate

# Then shutdown after waiting for 7 minutes
sudo shutdown -h +10