#!/usr/bin/env bash
set -euo pipefail

sudo apt-get update
sudo apt-get install -y rsyslog

sudo mkdir -p /var/log/remote
sudo chown -R syslog:adm /var/log/remote

sudo cp ./rsyslog_server.conf /etc/rsyslog.d/10-remote-server.conf

sudo systemctl restart rsyslog
sudo systemctl enable rsyslog

# открыть порты (если ufw включен)
sudo ufw allow 514/udp || true
sudo ufw allow 514/tcp || true

echo "[LOG SERVER] OK. Receiving on :514 tcp/udp"
