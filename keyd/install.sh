#!/bin/bash
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
echo "Installing keyd config"

git clone https://github.com/rvaiya/keyd "$DIR/src"
make -C "$DIR/src" && sudo make -C "$DIR/src" install
rm -rf "$DIR/src"

sudo systemctl enable keyd && sudo systemctl start keyd
sudo ln -sf "$DIR/default.conf" /etc/keyd/default.conf
sudo keyd reload
