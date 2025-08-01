#!/bin/bash

./alacritty/install.sh
./ghostty/install.sh
./nvim/install.sh
./git/install.sh
./neovim/install.sh
./tmux/install.sh
./zsh/install.sh
./nvm/install.sh

fixed_name="Jake Laurie"

read -rp "Enter your email address: " email

identity_file="$HOME/.gitconfig-identity"

cat > "$identity_file" <<EOF
[user]
    name = $fixed_name
    email = $email
EOF

echo "Wrote identity to $identity_file"
