#!/bin/bash
# script used to deploy the builder on a pi via the boot script
set -x
mkdir -p /var/tmp/clone
cd /var/tmp/clone && git clone https://github.com/cattlepi/cattlepi-scratch.git
cd /var/tmp/clone/cattlepi-scratch && git fetch origin +refs/pull/*/merge:refs/remotes/origin/pr/*
cd /var/tmp/clone/cattlepi-scratch && git reset --hard 97d0f45cc9487173747f24b9e332b78681bca6cb
sudo /var/tmp/clone/cattlepi-scratch/buildonpi/setup.sh
sudo /var/tmp/clone/cattlepi-scratch/buildonpi/install_monitor.sh