#!/bin/bash
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
echo "Installing kitty config"
mkdir -p ~/.config/kitty
ln -sf "$DIR/kitty.conf" ~/.config/kitty/kitty.conf
