#!/bin/bash
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
echo "Installing ideavimrc"
ln -sf "$DIR/ideavimrc" ~/.ideavimrc
