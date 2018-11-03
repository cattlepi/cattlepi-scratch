#!/bin/bash
set -x
export SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${SELFDIR}/functions.sh > /dev/null 2>&1
SELFME="$(basename "${BASH_SOURCE[0]}")"
guard_once ${SELFME}
if [ $GUARD -ne 0 ]; then
    echo "${SELFME} already setup"
    exit 1
fi

# install the needed packages
sudo apt-get install -y libffi-dev libssl-dev python-pip nginx
ufw allow http

cd ${SDROOT}/var/www/html && sudo wget -O ${RASPBIAN_FILE} -c ${RASPBIAN_LOCATION}
rm /var/www/html/${RASPBIAN_FILE}
ln -s /sd/var/www/html/${RASPBIAN_FILE} /var/www/html/${RASPBIAN_FILE}

# install virtualenv
sudo pip install virtualenv