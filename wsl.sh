#!/bin/bash

./alacritty/install.sh
./neovim/install.sh
./git/install.sh
./tmux/install.sh

# Enable systemctl
printf "[boot]\nsystemd=true" | sudo tee -a /etc/wsl.conf
echo "Restart wsl to init with systemd"
