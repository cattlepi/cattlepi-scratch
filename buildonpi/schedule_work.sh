#!/bin/bash
export SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${SELFDIR}/functions.sh > /dev/null 2>&1

if [ -f ${CURRENT_RUN} ]; then
    echo "job to schedule in ${CURRENT_RUN}"
    MESSAGEID=$(jq -r '.Messages[0].MessageId' ${CURRENT_RUN})
    MESSAGEBODY=$(jq -r '.Messages[0].Body' ${CURRENT_RUN})
    echo "message id is: ${MESSAGEID}"
    JOBDIR=${WORKDIR}/jobs/${MESSAGEID}
    mkdir -p ${JOBDIR}
    cp ${CURRENT_RUN} $JOBDIR/raw
    echo $MESSAGEBODY > $JOBDIR/job
    # find builder
    for BUILDERI in $(ls -1 ${SDROOT}/builders)
    do
        load_builder_state $BUILDERI
        if [ "$BUILDER_STATE" = "building" ]; then
            if [ "$BUILDER_TASK" = "$MESSAGEID" ]; then
                rm ${CURRENT_RUN}
                echo "already scheduled on $BUILDERI"
                exit 0
            fi
        fi
        if [ "$BUILDER_STATE" = "ready" ]; then
            BUILDER_STATE="building"
            BUILDER_TASK=${MESSAGEID}
            update_current_time
            BUILDER_LAST_CHECKED=${CURRENT_TIME}
            BUILDER_LAST_ACTION=${CURRENT_TIME}
            persist_builder_state $BUILDERI
            rm ${CURRENT_RUN}
            echo "scheduled on $BUILDERI"
            exit 0
        fi
    done
    echo "not scheduled. no workers free?"
else
    echo "no work pending"
fi


