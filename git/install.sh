#!/bin/bash
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
echo "Installing gitconfig"
ln -sf "$DIR/gitconfig" ~/.gitconfig

identity_file="$HOME/.gitconfig-identity"
if [[ ! -f "$identity_file" ]]; then
    read -rp "Enter your email address: " email
    cat > "$identity_file" <<EOF
[user]
    name = Jake Laurie
    email = $email
EOF
    echo "Wrote identity to $identity_file"
fi
