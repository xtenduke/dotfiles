#!/bin/bash

echo "Installing neovim config"

# Remove old config...
rm -rf ~/.config/nvim
ln -s "$(pwd)/nvim" ~/.config/nvim

sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
