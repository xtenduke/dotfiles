#!/bin/bash

./alacritty/install_wsl.sh
./neovim/install.sh
./git/install.sh
./tmux/install.sh
./zsh/install.sh

# Enable systemctl
printf "[boot]\nsystemd=true" | sudo tee -a /etc/wsl.conf
echo "Restart wsl to init with systemd"

echo "Reload your shell and run ./nvm/install.sh"
