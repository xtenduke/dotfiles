#!/bin/bash
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
echo "Installing ghostty config"
mkdir -p ~/.config/ghostty
ln -sf "$DIR/config" ~/.config/ghostty/config
