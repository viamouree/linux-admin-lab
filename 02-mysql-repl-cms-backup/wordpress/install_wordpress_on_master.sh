#!/usr/bin/env bash
set -e

sudo apt update
sudo apt install -y apache2 php php-mysql unzip wget

sudo mysql <<EOF
CREATE DATABASE wordpress;
CREATE USER 'wpuser'@'localhost' IDENTIFIED BY 'wppass';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'localhost';
FLUSH PRIVILEGES;
EOF

cd /tmp
wget https://wordpress.org/latest.zip
unzip latest.zip

sudo rm -rf /var/www/html/*
sudo cp -r wordpress/* /var/www/html/

sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
sudo sed -i 's/database_name_here/wordpress/' /var/www/html/wp-config.php
sudo sed -i 's/username_here/wpuser/' /var/www/html/wp-config.php
sudo sed -i 's/password_here/wppass/' /var/www/html/wp-config.php

sudo chown -R www-data:www-data /var/www/html
sudo systemctl restart apache2
