#!/bin/bash

echo "Install gitconfig"

# Remove old config...
rm -rf ~/.gitconfig
ln -s "$(pwd)/git/gitconfig" ~/.gitconfig

fixed_name="Jake Laurie"

read -rp "Enter your email address: " email

identity_file="$HOME/.gitconfig-identity"

cat > "$identity_file" <<EOF
[user]
    name = $fixed_name
    email = $email
EOF

echo "Wrote identity to $identity_file"
