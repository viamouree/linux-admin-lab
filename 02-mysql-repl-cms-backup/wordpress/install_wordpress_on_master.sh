#!/usr/bin/env bash
set -euo pipefail

DB_NAME="wordpress"
DB_USER="wpuser"
DB_PASS="wppass"

echo "[WP] Installing Apache+PHP..."
sudo apt-get update
sudo apt-get install -y apache2 php php-mysql libapache2-mod-php unzip wget

echo "[WP] Creating DB/user..."
sudo mysql <<EOF
CREATE DATABASE IF NOT EXISTS ${DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
EOF

echo "[WP] Downloading WordPress..."
cd /tmp
wget -q https://wordpress.org/latest.zip
unzip -q -o latest.zip

sudo rm -rf /var/www/html/*
sudo cp -r wordpress/* /var/www/html/

sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
sudo sed -i "s/database_name_here/${DB_NAME}/" /var/www/html/wp-config.php
sudo sed -i "s/username_here/${DB_USER}/" /var/www/html/wp-config.php
sudo sed -i "s/password_here/${DB_PASS}/" /var/www/html/wp-config.php

sudo chown -R www-data:www-data /var/www/html
sudo systemctl enable --now apache2

echo "[WP] Open in browser: http://192.168.118.129"
