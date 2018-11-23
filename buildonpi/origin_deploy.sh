#!/bin/bash
# script used to deploy the builder on a pi via the boot script
set -x

COMMIT_HASH="origin/master"
if [ "$#" -eq 1 ]; then
    COMMIT_HASH=$1
fi

mkdir -p /var/tmp/clone
cd /var/tmp/clone && git clone https://github.com/cattlepi/cattlepi-scratch.git
cd /var/tmp/clone/cattlepi-scratch && git fetch origin +refs/pull/*/merge:refs/remotes/origin/pr/*
cd /var/tmp/clone/cattlepi-scratch && git reset --hard ${COMMIT_HASH}
sudo /var/tmp/clone/cattlepi-scratch/buildonpi/setup.sh
sudo /var/tmp/clone/cattlepi-scratch/buildonpi/install_monitor.sh
sudo /var/tmp/clone/cattlepi-scratch/buildonpi/install_autobuild.sh
