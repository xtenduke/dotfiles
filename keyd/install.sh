#!/bin/bash
echo "installing keyd and linking config"

pushd keyd
git clone https://github.com/rvaiya/keyd src
pushd src
make && sudo make install
popd
rm -rf src
popd

sudo systemctl enable keyd && sudo systemctl start keyd

sudo ln -s "$(pwd)/keyd/default.conf" /etc/keyd/default.conf

sudo keyd reload
