#!/bin/bash

echo "Installing alacritty config"

ln -s "$(pwd)/alacritty.yml" ~/.config/alacritty.yml

mkdir -p ~/.config/alacritty/themes
git clone https://github.com/alacritty/alacritty-theme ~/.config/alacritty/themes
