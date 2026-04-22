#!/bin/bash
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
echo "Installing tmux config"
ln -sf "$DIR/tmux.conf" ~/.tmux.conf
