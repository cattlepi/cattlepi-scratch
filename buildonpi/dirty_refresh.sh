#!/bin/bash
# script used to iterate faster on the builder (deploy and run on the fly)
set -x
export SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${SELFDIR}/functions.sh > /dev/null 2>&1

if [ -d ${SDROOT} ]; then
    ifconfig
    echo "updating scripts"
    cp -R ${SELFDIR}/* ${SDROOT}/
    chmod +x ${SDROOT}/*.sh
fi