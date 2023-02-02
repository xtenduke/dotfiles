#!/bin/bash
set -e
echo "Running startup script"

echo "Calling powertop auto tune"
sudo /usr/sbin/powertop --auto-tune

echo "Finished starutp script"
