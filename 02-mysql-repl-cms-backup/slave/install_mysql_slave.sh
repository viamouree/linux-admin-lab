#!/usr/bin/env bash
set -e

sudo apt update
sudo apt install -y mysql-server

sudo sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' \
  /etc/mysql/mysql.conf.d/mysqld.cnf

sudo tee /etc/mysql/mysql.conf.d/slave.cnf >/dev/null <<EOF
[mysqld]
server-id=2
relay-log=mysql-relay-bin
read_only=ON
EOF

sudo systemctl restart mysql
