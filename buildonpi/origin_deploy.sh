#!/bin/bash
# script used to deploy the builder on a pi via the boot script
set -x
mkdir -p /var/tmp/clone
cd /var/tmp/clone && git clone https://github.com/cattlepi/cattlepi-scratch.git
cd /var/tmp/clone/cattlepi-scratch && git fetch origin +refs/pull/*/merge:refs/remotes/origin/pr/*
cd /var/tmp/clone/cattlepi-scratch && git reset --hard cc77668124063190cb6368c22c0d2fc974d1b2c3
sudo /var/tmp/clone/cattlepi-scratch/buildonpi/setup.sh
sudo /var/tmp/clone/cattlepi-scratch/buildonpi/install_monitor.sh