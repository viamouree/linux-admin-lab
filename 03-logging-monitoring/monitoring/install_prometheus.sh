#!/usr/bin/env bash
set -euo pipefail

VER="2.54.1"

sudo useradd --no-create-home --shell /usr/sbin/nologin prometheus || true
sudo mkdir -p /etc/prometheus /var/lib/prometheus

cd /tmp
wget -q "https://github.com/prometheus/prometheus/releases/download/v${VER}/prometheus-${VER}.linux-amd64.tar.gz"
tar -xzf "prometheus-${VER}.linux-amd64.tar.gz"

sudo cp "prometheus-${VER}.linux-amd64/prometheus" /usr/local/bin/prometheus
sudo cp "prometheus-${VER}.linux-amd64/promtool" /usr/local/bin/promtool

sudo cp ./prometheus.yml /etc/prometheus/prometheus.yml
sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus

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
