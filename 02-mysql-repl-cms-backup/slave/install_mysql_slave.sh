#!/usr/bin/env bash
set -euo pipefail

SLAVE_ID=2

echo "[SLAVE] Installing MySQL..."
sudo apt-get update
sudo apt-get install -y mysql-server

# Apply lab tuning (max_allowed_packet etc.)
sudo install -m 0644 -o root -g root \
  "$(dirname "$0")/../common/mysql_lab_tuning.cnf" \
  /etc/mysql/mysql.conf.d/mysql_lab_tuning.cnf

# Listen on all interfaces (optional but ok)
sudo sed -i 's/^\s*bind-address\s*=.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf || true

# Slave settings
sudo tee /etc/mysql/mysql.conf.d/replication-slave.cnf >/dev/null <<EOF
[mysqld]
server-id=${SLAVE_ID}
relay_log=mysql-relay-bin
read_only=ON
super_read_only=ON
EOF

sudo systemctl restart mysql

echo "[SLAVE] Done."
echo "[SLAVE] Next: run configure_replication.sh on this server."
