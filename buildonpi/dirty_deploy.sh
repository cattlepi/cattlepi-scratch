#!/bin/bash
# script used to iterate faster on the builder (deploy and run on the fly)
set -x
export SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TARGET="192.168.1.87"

tar czvf /tmp/builder.tar.gz -C $SELFDIR .
scp /tmp/builder.tar.gz pi@${TARGET}:/tmp/
sshi pi@${TARGET} tar -xzvf /tmp/builder.tar.gz -C /sd
sshi pi@${TARGET} chmod +x /sd/*.sh