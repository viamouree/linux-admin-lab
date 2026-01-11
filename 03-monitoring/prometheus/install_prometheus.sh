#!/usr/bin/env bash
set -e

wget https://github.com/prometheus/prometheus/releases/download/v2.54.1/prometheus-2.54.1.linux-amd64.tar.gz
tar xzf prometheus-2.54.1.linux-amd64.tar.gz

sudo useradd -rs /bin/false prometheus || true
sudo mkdir -p /etc/prometheus /var/lib/prometheus

sudo cp prometheus-2.54.1.linux-amd64/prometheus /usr/local/bin/
sudo cp prometheus-2.54.1.linux-amd64/promtool /usr/local/bin/
sudo cp prometheus.yml /etc/prometheus/

sudo tee /etc/systemd/system/prometheus.service >/dev/null <<EOF
[Unit]
Description=Prometheus

[Service]
User=prometheus
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now prometheus
