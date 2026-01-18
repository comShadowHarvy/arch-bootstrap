#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

mkdir -p /etc/systemd/system/ollama.service.d
cat <<EOF > /etc/systemd/system/ollama.service.d/override.conf
[Service]
Environment="OLLAMA_HOST=0.0.0.0"
EOF

systemctl daemon-reload
systemctl restart ollama.service

echo "ollama service configured to accept remote connections."