#!/bin/bash

echo "Install ideavimrc"
# Remove old config
rm -rf ~/.ideavimrc
ln -s "$(pwd)/jetbrains/ideavimrc" ~/.ideavimrc

