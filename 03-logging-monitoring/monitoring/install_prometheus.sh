#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VER="2.54.1"

# Create user and dirs
sudo useradd --no-create-home --shell /usr/sbin/nologin prometheus || true
sudo mkdir -p /etc/prometheus /var/lib/prometheus

# Download and install Prometheus binaries
cd /tmp
wget -q "https://github.com/prometheus/prometheus/releases/download/v${VER}/prometheus-${VER}.linux-amd64.tar.gz"
tar -xzf "prometheus-${VER}.linux-amd64.tar.gz"

sudo cp "prometheus-${VER}.linux-amd64/prometheus" /usr/local/bin/prometheus
sudo cp "prometheus-${VER}.linux-amd64/promtool" /usr/local/bin/promtool

# Copy config (use script directory, not current working directory)
sudo cp "${SCRIPT_DIR}/prometheus.yml" /etc/prometheus/prometheus.yml

# Permissions
sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus

# Systemd unit
sudo tee /etc/systemd/system/prometheus.service >/dev/null <<'EOF'
[Unit]
Description=Prometheus
After=network-online.target
Wants=network-online.target

[Service]
User=prometheus
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus \
  --web.listen-address=:9090

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now prometheus

echo "[PROMETHEUS] OK :9090"
echo "Open: http://$(hostname -I | awk '{print $1}'):9090  (or http://192.168.118.129:9090)"
