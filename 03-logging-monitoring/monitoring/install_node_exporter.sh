#!/usr/bin/env bash
set -euo pipefail

VER="1.7.0"
cd /tmp
wget -q "https://github.com/prometheus/node_exporter/releases/download/v${VER}/node_exporter-${VER}.linux-amd64.tar.gz"
tar -xzf "node_exporter-${VER}.linux-amd64.tar.gz"
sudo cp "node_exporter-${VER}.linux-amd64/node_exporter" /usr/local/bin/node_exporter

sudo useradd --no-create-home --shell /usr/sbin/nologin node_exporter || true

sudo tee /etc/systemd/system/node_exporter.service >/dev/null <<'EOF'
[Unit]
Description=Prometheus Node Exporter
After=network-online.target
Wants=network-online.target

[Service]
User=node_exporter
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now node_exporter

echo "[NODE_EXPORTER] OK :9100"
