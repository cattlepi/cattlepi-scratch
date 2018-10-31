#!/bin/bash
export SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${SELFDIR}/functions.sh > /dev/null 2>&1
BUILDER=$1
BUILDLOCATION=$2
echo "running with builder ${BUILDER} in ${BUILDLOCATION}"
export BUILDER_NODE=${BUILDER}
cd ${BUILDLOCATION} && git clone https://github.com/cattlepi/cattlepi.git
cd ${BUILDLOCATION}/cattlepi && make envsetup
cd ${BUILDLOCATION}/cattlepi && make test_noop

echo ""
echo "-------------------------"
echo "build done"
echo "-------------------------"

