#!/bin/bash
export SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${SELFDIR}/functions.sh > /dev/null 2>&1

update_current_time
time_diff $CURRENT_TIME

for BUILDERI in $(ls -1 ${SDROOT}/builders)
do
    echo "found builder ${BUILDERI}"
    load_builder_state $BUILDERI
    update_current_time
    BUILDER_LAST_CHECKED=${CURRENT_TIME}
    echo "make some decisions in between"
    persist_builder_state $BUILDERI
    echo "---------------------------"
    cat ${SDROOT}/builders/${BUILDERID}/state
    echo "---------------------------"
done