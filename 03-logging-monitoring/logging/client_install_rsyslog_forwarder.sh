#!/usr/bin/env bash
set -euo pipefail

sudo apt-get update
sudo apt-get install -y rsyslog

sudo cp ./rsyslog_client_forward.conf /etc/rsyslog.d/90-forward-to-logserver.conf

sudo systemctl restart rsyslog
sudo systemctl enable rsyslog

echo "[LOG CLIENT] OK. Forwarding to 192.168.118.128:514"
