#!/bin/bash

echo "Install tmux config"

# Remove old config...
rm -rf ~/.tmux.conf
ln -s "$(pwd)/tmux/tmux.conf" ~/.tmux.conf
