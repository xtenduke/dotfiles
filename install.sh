#!/bin/bash
set -e

cd "$(dirname "$0")"

./alacritty/install.sh
./ghostty/install.sh
./git/install.sh
./neovim/install.sh
./tmux/install.sh
./zellij/install.sh
./zsh/install.sh
./scripts/install.sh
./nvm/install.sh
