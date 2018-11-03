#!/bin/bash
set -x
export SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${SELFDIR}/functions.sh > /dev/null 2>&1
SELFME="$(basename "${BASH_SOURCE[0]}")"
guard_once ${SELFME}
if [ $GUARD -ne 0 ]; then
    echo "${SELFME} already setup"
    return 1
fi

export RASPBIAN_LOCATION=http://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2018-06-29/2018-06-27-raspbian-stretch-lite.zip
export RASPBIAN_FILE=2018-06-27-raspbian-stretch-lite.zip