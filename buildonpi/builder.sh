#!/bin/bash
export SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${SELFDIR}/functions.sh > /dev/null 2>&1
BUILDER=$1
echo "running with builder ${BUILDER}"
BUILDLOCATION=${BUILDERSDIR}/${BUILDER}/build
rm -rf ${BUILDLOCATION}
mkdir -p ${BUILDLOCATION}
export BUILDER_NODE=${BUILDER}
cd ${BUILDLOCATION} && git clone https://github.com/cattlepi/cattlepi.git
cd ${BUILDLOCATION}/cattlepi && make envsetup

sleep 300
exit 0