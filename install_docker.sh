#!/bin/bash

# swiped from https://gist.githubusercontent.com/EvgenyOrekhov/1ed8a4466efd0a59d73a11d753c0167b/raw/00094f684856dd59745d0d1b01041dcbda95b1bf/install-docker.sh

set -o errexit
set -o nounset

IFS=$(printf '\n\t')

# Docker
sudo apt remove --yes docker docker-engine docker.io containerd runc || true
sudo apt update
sudo apt --yes --no-install-recommends install apt-transport-https ca-certificates
wget --quiet --output-document=- https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository --yes "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu $(lsb_release --codename --short) stable"
sudo apt update
sudo apt --yes --no-install-recommends install docker-ce docker-ce-cli containerd.io
sudo usermod --append --groups docker "$USER"
## Depends on systemd if wsl
sudo systemctl enable docker
printf '\nDocker installed successfully\n\n'
newgrp docker

printf 'Waiting for Docker to start...\n\n'
sleep 5

# Docker Compose
# just install compose from repos..
sudo apt install -y docker-compose

