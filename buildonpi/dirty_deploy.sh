#!/bin/bash
# script used to iterate faster on the builder (deploy and run on the fly)
set -x
export SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TARGET="192.168.1.87"
ssh-keygen -f "/home/mircea/.ssh/known_hosts" -R ${TARGET}

tar czvf /tmp/builder.tar.gz -C $SELFDIR .
sshi pi@${TARGET} mkdir -p /tmp/sd
scp -o StrictHostKeyChecking=no /tmp/builder.tar.gz pi@${TARGET}:/tmp/
sshi pi@${TARGET} tar -xzvf /tmp/builder.tar.gz -C /tmp/sd
sshi pi@${TARGET} /tmp/sd/setup.sh