#!/bin/bash
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
echo "Installing neovim config"
mkdir -p ~/.config
ln -sf "$DIR/nvim" ~/.config/nvim

curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
