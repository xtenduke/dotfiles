#!/bin/bash
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
echo "Installing scripts"
ln -sf "$DIR/scripts" ~/scripts
