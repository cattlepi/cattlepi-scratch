#!/bin/bash
# script used to deploy the builder on a pi via the boot script
set -x
mkdir -p /var/tmp/clone
cd /var/tmp/clone && git clone https://github.com/cattlepi/cattlepi-scratch.git
cd /var/tmp/clone/cattlepi-scratch && git fetch origin +refs/pull/*/merge:refs/remotes/origin/pr/*
cd /var/tmp/clone/cattlepi-scratch && git reset --hard bba1d39c7835891cd2f0d0310025ab6bb37c7b23
sudo /var/tmp/clone/cattlepi-scratch/buildonpi/setup.sh
sudo /var/tmp/clone/cattlepi-scratch/buildonpi/install_monitor.sh