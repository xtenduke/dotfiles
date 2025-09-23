#!/bin/bash

./git/install.sh

# Setup ssh integration for 1password
gitconfig="$HOME/.gitconfig"
cat >> "$gitconfig" <<EOF
[core]
  sshCommand = ssh.exe
EOF

