#!/bin/bash -xe

version=$(lsb_release -sr)
codename=$(lsb_release -sc)
wget -O - https://repo.saltstack.com/apt/ubuntu/$version/amd64/latest/SALTSTACK-GPG-KEY.pub | apt-key add -
echo deb http://repo.saltstack.com/apt/ubuntu/$version/amd64/latest $codename main | tee /etc/apt/sources.list.d/saltstack.list

export DEBIAN_FRONTEND=noninteractive
apt-get update -q
apt-get upgrade -y
apt-get install -y language-pack-en
apt-get install -y salt-minion

systemctl enable salt-minion
systemctl start salt-minion
