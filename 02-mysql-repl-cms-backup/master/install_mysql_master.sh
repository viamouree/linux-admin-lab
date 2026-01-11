#!/usr/bin/env bash
set -e

sudo apt update
sudo apt install -y mysql-server

sudo sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' \
  /etc/mysql/mysql.conf.d/mysqld.cnf

sudo tee /etc/mysql/mysql.conf.d/master.cnf >/dev/null <<EOF
[mysqld]
server-id=1
log_bin=mysql-bin
binlog_format=ROW
EOF

sudo systemctl restart mysql

sudo mysql <<EOF
CREATE USER 'repl'@'192.168.118.%' IDENTIFIED BY 'replpass';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'192.168.118.%';
FLUSH PRIVILEGES;
EOF
