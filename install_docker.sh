#!/bin/bash

# swiped from https://gist.githubusercontent.com/EvgenyOrekhov/1ed8a4466efd0a59d73a11d753c0167b/raw/00094f684856dd59745d0d1b01041dcbda95b1bf/install-docker.sh

set -o errexit
set -o nounset

IFS=$(printf '\n\t')

# Docker
sudo apt remove --yes docker docker-engine docker.io containerd runc || true
sudo apt update
sudo apt --yes --no-install-recommends install apt-transport-https ca-certificates

sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg 

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

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

