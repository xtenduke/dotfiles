#!/bin/bash

echo "Install gitconfig"

# Remove old config...
rm -rf ~/.gitconfig
ln -s "$(pwd)/git/gitconfig" ~/.gitconfig

