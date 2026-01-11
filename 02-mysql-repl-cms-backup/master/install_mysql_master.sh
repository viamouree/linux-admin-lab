#!/usr/bin/env bash
set -euo pipefail

MASTER_ID=1
REPL_USER="repl"
REPL_PASS="replpass"
REPL_NET="192.168.118.%"

echo "[MASTER] Installing MySQL..."
sudo apt-get update
sudo apt-get install -y mysql-server

# Listen on all interfaces (lab LAN)
sudo sed -i 's/^\s*bind-address\s*=.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf || true

# Enable binlog + safe tuning to avoid replication issues
sudo tee /etc/mysql/mysql.conf.d/replication-master.cnf >/dev/null <<EOF
[mysqld]
server-id=${MASTER_ID}
log_bin=mysql-bin
binlog_format=ROW
max_allowed_packet=256M
EOF

sudo systemctl restart mysql

# If ufw is enabled, allow MySQL (harmless if ufw is off)
sudo ufw allow 3306/tcp >/dev/null 2>&1 || true

echo "[MASTER] Creating/forcing replication user (MySQL 8 auth fix)..."
sudo mysql <<EOF
CREATE USER IF NOT EXISTS '${REPL_USER}'@'${REPL_NET}'
  IDENTIFIED WITH mysql_native_password BY '${REPL_PASS}';

ALTER USER '${REPL_USER}'@'${REPL_NET}'
  IDENTIFIED WITH mysql_native_password BY '${REPL_PASS}';

GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO '${REPL_USER}'@'${REPL_NET}';
FLUSH PRIVILEGES;
EOF

echo "[MASTER] Creating lab database for replication check (labdb)..."
sudo mysql -e "CREATE DATABASE IF NOT EXISTS labdb;"
sudo mysql -e "CREATE TABLE IF NOT EXISTS labdb.messages(
  id INT AUTO_INCREMENT PRIMARY KEY,
  txt VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);"
sudo mysql -e "INSERT INTO labdb.messages(txt) VALUES('master init');"

echo "[MASTER] OK"
echo "[MASTER] Check coordinates:"
echo "  sudo mysql -e \"SHOW MASTER STATUS\\G\""
echo "[MASTER] Check test data:"
echo "  sudo mysql -e \"SELECT * FROM labdb.messages;\""
