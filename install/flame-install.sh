#!/usr/bin/env bash

# Copyright (c) 2021-2026 community-scripts ORG
# Author: CrazyWolf13
# License: MIT | https://github.com/community-scripts/ProxmoxVED/raw/main/LICENSE
# Source: https://github.com/pawelmalak/flame

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

NODE_VERSION="22" setup_nodejs

fetch_and_deploy_gh_release "flame" "pawelmalak/flame" "tarball"

msg_info "Setting up Flame"
cd /opt/flame
$STD npm run init-server
cd /opt/flame/client
$STD npm install
$STD npm run build
cd /opt/flame
mkdir -p public data
cp -r client/build/. public/
cat <<EOF >/opt/flame/.env
NODE_ENV=production
PASSWORD=
EOF
msg_ok "Set up Flame"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/flame.service
[Unit]
Description=Flame Startpage
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/flame
ExecStart=/usr/bin/node server.js
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now flame
msg_ok "Created Service"

motd_ssh
customize
cleanup_lxc
