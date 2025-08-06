#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "🔄 Updating system..."
sudo apt update
sudo apt install -y software-properties-common wget apt-transport-https

echo "🔑 Adding Grafana GPG key and repo..."
sudo mkdir -p /etc/apt/keyrings
wget -q -O - https://apt.grafana.com/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/grafana.gpg
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee /etc/apt/sources.list.d/grafana.list

echo "🔄 Updating package list with Grafana repo..."
sudo apt update

echo "📦 Installing Grafana..."
sudo apt install -y grafana

echo "🛠️ Enabling and starting Grafana service..."
sudo systemctl daemon-reload
sudo systemctl enable grafana-server
sudo systemctl start grafana-server

echo "✅ Grafana is installed and running!"
echo "🌐 Access it at: http://<your-vm-ip>:3000"
echo "🔐 Default login: admin / admin (you will be prompted to change on first login)"
