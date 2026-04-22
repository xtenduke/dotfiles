#!/bin/bash
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
echo "Installing zsh config"

if [[ ! -d ~/powerlevel10k ]]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
fi

ln -sf "$DIR/p10k.zsh" ~/.p10k.zsh
ln -sf "$DIR/zshrc" ~/.zshrc

chsh -s "$(which zsh)"
