#!/bin/bash
export SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${SELFDIR}/functions.sh > /dev/null 2>&1
source $WORKDIR/cattlepi/tools/venv/bin/activate > /dev/null 2>&1

BUILDER=$1
BUILDLOCATION=$2
load_builder_state $BUILDER
github_status_update $BUILDER_TASK "pending"

JOBDIR=${WORKDIR}/jobs/${BUILDER_TASK}
COMMITID=$(head -1 ${BUILDER_TASK}/commit)
SQSQ=$(cat /tmp/current_config | jq -r '.config.buildcontrol.aws_sqs_queue')

update_current_time
BUILDER_LAST_ACTION=${CURRENT_TIME}
persist_builder_state $BUILDER
echo "running with builder ${BUILDER} in ${BUILDLOCATION}"
export BUILDER_NODE=${BUILDER}
cd ${BUILDLOCATION} && git clone https://github.com/cattlepi/cattlepi.git
cd ${BUILDLOCATION}/cattlepi && git reset --hard ${COMMITID}
cd ${BUILDLOCATION}/cattlepi && make envsetup

# test
cd ${BUILDLOCATION}/cattlepi && make test_noop
# update_current_time
# BUILDER_LAST_ACTION=${CURRENT_TIME}
# persist_builder_state $BUILDER

# # actual image
# cd ${BUILDLOCATION}/cattlepi && make raspbian_cattlepi
BUILDRESULT=$?

echo ""
echo "-------------------------"
if [ $BUILDRESULT -ne 0 ]; then
    github_status_update $BUILDER_TASK "failure"
else
    github_status_update $BUILDER_TASK "success"
fi

# ack the message in the queue
RECEIPT=$(head -1 ${BUILDER_TASK}/handle)
aws sqs delete-message --queue-url "${SQSQ}" --receipt-handle "${RECEIPT}"
# upload the logs

# update the build state
update_current_time
BUILDER_LAST_ACTION=${CURRENT_TIME}
BUILDER_STATE="rebuild"
persist_builder_state $BUILDER
echo "-------------------------"