#!/bin/bash

echo "Installing ideavimrc for WSL!"

read -p 'Whats your win username??: ' username

ln -s "$(pwd)/jetbrains/ideavimrc" /mnt/c/Users/"$username"/.ideavimrc
