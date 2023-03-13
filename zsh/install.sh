#!/bin/bash

echo "Install zsh"

# Remove old config...
rm -rf ~/.zshrc

# Install from os repo
sudo apt install -y zsh

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k

ln -s "$(pwd)/zsh/p10k.zsh" ~/.p10k.zsh
ln -s "$(pwd)/zsh/zshrc" ~/.zshrc

# change shell
chsh -s $(which zsh)
