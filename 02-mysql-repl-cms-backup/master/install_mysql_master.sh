#!/usr/bin/env bash
set -euo pipefail

MASTER_ID=1
REPL_USER="repl"
REPL_PASS="replpass"
REPL_NET="192.168.118.%"

sudo apt-get update
sudo apt-get install -y mysql-server

# слушаем сеть (для репликации)
sudo sed -i 's/^\s*bind-address\s*=.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf || true

# включаем binlog
sudo tee /etc/mysql/mysql.conf.d/replication-master.cnf >/dev/null <<EOF
[mysqld]
server-id=${MASTER_ID}
log_bin=mysql-bin
binlog_format=ROW
max_allowed_packet=256M
EOF

sudo systemctl restart mysql

# MySQL 8: фиксируем плагин, чтобы не требовал TLS
sudo mysql <<EOF
CREATE USER IF NOT EXISTS '${REPL_USER}'@'${REPL_NET}'
  IDENTIFIED WITH mysql_native_password BY '${REPL_PASS}';
ALTER USER '${REPL_USER}'@'${REPL_NET}'
  IDENTIFIED WITH mysql_native_password BY '${REPL_PASS}';
GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO '${REPL_USER}'@'${REPL_NET}';
FLUSH PRIVILEGES;
EOF

# учебная БД (для проверки репликации)
sudo mysql -e "CREATE DATABASE IF NOT EXISTS labdb;"
sudo mysql labdb -e "CREATE TABLE IF NOT EXISTS messages(id INT AUTO_INCREMENT PRIMARY KEY, txt VARCHAR(100), created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);"
sudo mysql labdb -e "INSERT INTO messages(txt) VALUES('master init');"

echo "[MASTER] OK"
echo "Run on master to see coordinates: sudo mysql -e \"SHOW MASTER STATUS\\G\""
