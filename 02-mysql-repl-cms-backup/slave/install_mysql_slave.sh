#!/usr/bin/env bash
set -euo pipefail

SLAVE_ID=2

sudo apt-get update
sudo apt-get install -y mysql-server

sudo sed -i 's/^\s*bind-address\s*=.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf || true

sudo tee /etc/mysql/mysql.conf.d/replication-slave.cnf >/dev/null <<EOF
[mysqld]
server-id=${SLAVE_ID}
relay_log=mysql-relay-bin
read_only=ON
super_read_only=ON
max_allowed_packet=256M
EOF

sudo systemctl restart mysql
echo "[SLAVE] OK"
