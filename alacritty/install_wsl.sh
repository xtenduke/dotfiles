#!/bin/bash

echo "Installing alacritty for WSL!"

read -p 'Whats your win username??: ' username

mkdir -p /mnt/c/Users/"$username"/AppData/alacritty
ln -s "$(pwd)/alacritty/alacritty.toml" /mnt/c/Users/"$username"/AppData/alacritty/alacritty.toml
