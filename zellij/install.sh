#!/bin/bash
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
echo "Installing zellij config"
mkdir -p ~/.config/zellij
ln -sf "$DIR/config.kdl" ~/.config/zellij/config.kdl
