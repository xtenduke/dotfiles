#!/bin/bash

echo "Installing scripts"

unlink ~/scripts
ln -s "$(pwd)/scripts/scripts" ~/scripts
