#!/usr/bin/env bash
set -euo pipefail

sudo apt-get update
sudo apt-get install -y apache2

HOST="$(hostname)"
IP="$(hostname -I | awk '{print $1}')"

sudo tee /var/www/html/index.html >/dev/null <<EOF
Hello World from backend!
Host: ${HOST}
IP: ${IP}
Time: $(date -Is)
EOF

sudo systemctl enable --now apache2

