#!/bin/bash
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
echo "Installing alacritty config"
ln -sf "$DIR/alacritty.toml" ~/.config/alacritty.toml
