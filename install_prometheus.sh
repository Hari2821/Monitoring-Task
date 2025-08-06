#!/bin/bash

# Exit on any error
set -e

PROM_VERSION="2.52.0"
PROM_USER="prometheus"

echo "🔄 Updating system..."
sudo apt update
sudo apt install -y wget tar

echo "📁 Creating Prometheus user..."
sudo useradd --no-create-home --shell /bin/false $PROM_USER

echo "📥 Downloading Prometheus v$PROM_VERSION..."
cd /opt
sudo wget https://github.com/prometheus/prometheus/releases/download/v${PROM_VERSION}/prometheus-${PROM_VERSION}.linux-amd64.tar.gz

echo "📦 Extracting Prometheus..."
sudo tar -xzf prometheus-${PROM_VERSION}.linux-amd64.tar.gz
sudo mv prometheus-${PROM_VERSION}.linux-amd64 prometheus

echo "🚚 Moving binaries..."
cd /opt/prometheus
sudo cp prometheus promtool /usr/local/bin/

echo "📂 Setting up config directories..."
sudo mkdir -p /etc/prometheus /var/lib/prometheus
sudo cp -r consoles console_libraries prometheus.yml /etc/prometheus/

echo "🔐 Setting permissions..."
sudo chown -R $PROM_USER:$PROM_USER /etc/prometheus /var/lib/prometheus /usr/local/bin/prometheus /usr/local/bin/promtool

echo "📝 Creating systemd service..."
sudo tee /etc/systemd/system/prometheus.service > /dev/null <<EOF
[Unit]
Description=Prometheus Monitoring
Wants=network-online.target
After=network-online.target

[Service]
User=$PROM_USER
ExecStart=/usr/local/bin/prometheus \\
  --config.file=/etc/prometheus/prometheus.yml \\
  --storage.tsdb.path=/var/lib/prometheus/ \\
  --web.console.templates=/etc/prometheus/consoles \\
  --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=default.target
EOF

echo "🔄 Reloading systemd..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload

echo "🚀 Starting Prometheus..."
sudo systemctl enable prometheus
sudo systemctl start prometheus

echo "✅ Prometheus is running on port 9090!"
echo "🌐 Access: http://<your-vm-ip>:9090"
