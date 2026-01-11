#!/usr/bin/env bash
set -euo pipefail

sudo apt-get update
sudo apt-get install -y nginx

sudo rm -f /etc/nginx/sites-enabled/default

sudo tee /etc/nginx/sites-available/lb.conf >/dev/null < ./nginx_lb.conf
sudo ln -sf /etc/nginx/sites-available/lb.conf /etc/nginx/sites-enabled/lb.conf

sudo nginx -t
sudo systemctl enable --now nginx
sudo systemctl reload nginx
