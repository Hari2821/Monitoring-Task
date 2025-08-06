#!/bin/bash

set -e

NODE_EXPORTER_VERSION="1.8.1"

echo "📥 Downloading Node Exporter v$NODE_EXPORTER_VERSION..."
cd /opt
wget https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz

echo "📦 Extracting..."
tar -xzf node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
mv node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64 node_exporter

echo "🔧 Creating node_exporter user..."
useradd -rs /bin/false node_exporter || true

echo "🚚 Moving binary to /usr/local/bin..."
cp node_exporter/node_exporter /usr/local/bin/

echo "🛠️ Creating systemd service..."
cat <<EOF | tee /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=default.target
EOF

echo "🔄 Reloading and starting Node Exporter..."
systemctl daemon-reload
systemctl enable node_exporter
systemctl start node_exporter

echo "✅ Node Exporter is running on port 9100"
echo "🌐 Test: curl http://localhost:9100/metrics"
echo "➡️ Don't forget to add this job to Prometheus config:"
echo '
  - job_name: "node_exporter"
    static_configs:
      - targets: ["localhost:9100"]
'

