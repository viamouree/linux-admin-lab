#!/usr/bin/env bash
set -euo pipefail

MASTER_ID=1
REPL_USER="repl"
REPL_PASS="replpass"
REPL_HOST="192.168.118.%"

echo "[MASTER] Installing MySQL..."
sudo apt-get update
sudo apt-get install -y mysql-server

# Apply lab tuning (max_allowed_packet etc.)
sudo install -m 0644 -o root -g root \
  "$(dirname "$0")/../common/mysql_lab_tuning.cnf" \
  /etc/mysql/mysql.conf.d/mysql_lab_tuning.cnf

# Listen on all interfaces (lab LAN)
sudo sed -i 's/^\s*bind-address\s*=.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf || true

# Enable binlog + replication settings
sudo tee /etc/mysql/mysql.conf.d/replication-master.cnf >/dev/null <<EOF
[mysqld]
server-id=${MASTER_ID}
log_bin=mysql-bin
binlog_format=ROW
EOF

sudo systemctl restart mysql

echo "[MASTER] Creating/forcing replication user with mysql_native_password (avoid TLS requirement)..."
sudo mysql <<EOF
CREATE USER IF NOT EXISTS '${REPL_USER}'@'${REPL_HOST}'
  IDENTIFIED WITH mysql_native_password BY '${REPL_PASS}';

ALTER USER '${REPL_USER}'@'${REPL_HOST}'
  IDENTIFIED WITH mysql_native_password BY '${REPL_PASS}';

GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO '${REPL_USER}'@'${REPL_HOST}';
FLUSH PRIVILEGES;
EOF

echo "[MASTER] Creating lab database for replication check (labdb)..."
sudo mysql -e "CREATE DATABASE IF NOT EXISTS labdb;"

echo "[MASTER] Done."
echo "[MASTER] Check master status:"
echo "  sudo mysql -e \"SHOW MASTER STATUS\\G\""

