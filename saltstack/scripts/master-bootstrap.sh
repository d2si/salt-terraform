#!/bin/bash -xe

apt-get update

wget -O bootstrap_salt.sh https://bootstrap.saltstack.com
bash bootstrap_salt.sh
