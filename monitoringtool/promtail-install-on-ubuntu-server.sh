#!/bin/bash

# Step 1: Download and Install Promtail
echo "Downloading Promtail..."
wget -q https://whitelable-resources.s3.us-east-1.amazonaws.com/promtail-linux-amd64 -O promtail
chmod +x promtail
sudo mv promtail /usr/local/bin/
echo "Promtail installed successfully."

# Step 2: Create Promtail Configuration File
CONFIG_FILE="/etc/promtail-config.yml"
echo "Creating Promtail configuration file..."
sudo tee $CONFIG_FILE > /dev/null <<EOL
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /tmp/positions.yaml

clients:
  - url: http://18.116.41.217:3100/loki/api/v1/push

scrape_configs:
  - job_name: "Application"
    static_configs:
      - targets:
          - localhost
        labels:
          job: "ValhallaLogs-system-logs"
          host: "ValhallaLogs-system"
          __path__: "/var/log/*.log"
EOL
echo "Promtail configuration file created at $CONFIG_FILE."

# Step 3: Test Promtail Manually
# echo "Testing Promtail manually..."
# promtail --config.file=$CONFIG_FILE

# Step 4: Create Promtail Systemd Service
SERVICE_FILE="/etc/systemd/system/promtail.service"
echo "Creating Promtail systemd service..."
sudo tee $SERVICE_FILE > /dev/null <<EOL
[Unit]
Description=Promtail Service
After=network.target

[Service]
ExecStart=/usr/local/bin/promtail -config.file=/etc/promtail-config.yml
Restart=always
User=root
ExecReload=/bin/kill -HUP \$MAINPID
KillMode=process

[Install]
WantedBy=multi-user.target
EOL
echo "Promtail systemd service file created at $SERVICE_FILE."

# Step 5: Reload, Enable, and Start Promtail Service
echo "Starting Promtail service..."
sudo systemctl daemon-reload
sudo systemctl start promtail
sudo systemctl enable promtail
sudo systemctl restart promtail
sudo systemctl status promtail --no-pager