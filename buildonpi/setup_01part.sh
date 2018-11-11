#!/bin/bash
export SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${SELFDIR}/functions.sh > /dev/null 2>&1
SELFME="$(basename "${BASH_SOURCE[0]}")"
guard_once ${SELFME}
if [ $GUARD -ne 0 ]; then
    echo "${SELFME} already setup"
    return 1
fi

sudo umount ${SDROOT}
sudo mkdir -p ${SDROOT}
sudo mount /dev/mmcblk0p2 ${SDROOT}
sudo rm -rf ${SDROOT}/*
sudo chown pi:pi ${SDROOT}

sudo umount ${SDROOT}/tmp
test -d ${SDROOT}/tmp || sudo mkdir -m 1777 ${SDROOT}/tmp
sudo mount --bind ${SDROOT}/tmp /tmp

# rerun the update after the tmp update
/etc/cattlepi/autoupdate.sh