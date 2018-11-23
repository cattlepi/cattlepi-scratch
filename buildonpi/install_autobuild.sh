#!/bin/bash
export SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${SELFDIR}/functions.sh > /dev/null 2>&1

echo "0 */3 * * *   pi    touch ${AUTOBUILDREQUESTED}" > /etc/cron.d/cattlepi_autobuild