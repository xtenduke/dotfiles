#!/bin/bash

echo "Installing ghostty config"

mkdir -p ~/.config/ghostty
ln -s "$(pwd)/ghostty/config" ~/.config/ghostty/config
