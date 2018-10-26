export SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TARGET="192.168.1.87"
SCRIPT="schedule_work.sh"
for CSP in $(ls -1 ${SELFDIR})
do
    scp $CSP pi@${TARGET}:/sd/
    sshi pi@${TARGET} chmod +x /sd/$CSP
done