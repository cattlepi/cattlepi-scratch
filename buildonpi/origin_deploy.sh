#!/bin/bash
# script used to deploy the builder on a pi via the boot script
set -x
mkdir -p /var/tmp/clone
cd /var/tmp/clone && git clone https://github.com/cattlepi/cattlepi-scratch.git
cd /var/tmp/clone/cattlepi-scratch && git fetch origin +refs/pull/*/merge:refs/remotes/origin/pr/*
cd /var/tmp/clone/cattlepi-scratch && git reset --hard abc20d88cd456898c460b82e0b9481119ed3acd4
sudo /var/tmp/clone/cattlepi-scratch/buildonpi/setup.sh
sudo /var/tmp/clone/cattlepi-scratch/buildonpi/install_monitor.sh