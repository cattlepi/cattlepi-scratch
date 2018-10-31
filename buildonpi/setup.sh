#!/bin/bash
set -x
export SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${SELFDIR}/functions.sh > /dev/null 2>&1

# sample config that can be used for build control - only relevant part shown
# {
#   "config": {
#     "buildcontrol": {
#       "aws_ak": "aws access_key",
#       "aws_sk": "aws secret key",
#       "aws_sqs_queue": "aws sqs queue URL",
#       "build_machines": [
#         "ip of build machine1",
#         "ip of build machine2",
#         "ip of build machine3"
#       ],
#       "builders_api_key": "cattlepi api key of the build machines",
#       "gh_token": "github token - used to make api calls to github"
#     },
#   }
# }

sudo umount ${SDROOT}
sudo mkdir -p ${SDROOT}
sudo mount /dev/mmcblk0p2 ${SDROOT}
# sudo rm -rf ${SDROOT}/*
sudo chown pi:pi ${SDROOT}

umount /${SDROOT}/tmp
test -d /${SDROOT}/tmp || mkdir -m 1777 /${SDROOT}/tmp
mount --bind /${SDROOT}/tmp /tmp

# install the needed packages
sudo apt-get install -y libffi-dev libssl-dev python-pip nginx
ufw allow http

mkdir -p ${SDROOT}/var/www/html
cd ${SDROOT}/var/www/html && sudo wget -c http://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2018-06-29/2018-06-27-raspbian-stretch-lite.zip
rm /var/www/html/2018-06-27-raspbian-stretch-lite.zip
ln -s /sd/var/www/html/2018-06-27-raspbian-stretch-lite.zip /var/www/html/2018-06-27-raspbian-stretch-lite.zip

# install virtualenv
sudo pip install virtualenv

# setup the environment vars
mkdir -p ${SDROOT}/.aws
cat <<'EOF' > ${SDROOT}/.aws/config
[default]
output = json
region = us-west-2
EOF

echo "[default]" > ${SDROOT}/.aws/credentials
echo "aws_access_key_id = $(jq -r ".config.buildcontrol.aws_ak" /tmp/current_config)" >> ${SDROOT}/.aws/credentials
echo "aws_secret_access_key = $(jq -r ".config.buildcontrol.aws_sk" /tmp/current_config)" >> ${SDROOT}/.aws/credentials

# generate ssh keys
sudo rm -rf /home/pi/.ssh/id_*
su - pi -c "ssh-keygen -f /home/pi/.ssh/id_rsa -N '' -t rsa -b 4096 -C "hello@cattlepi.com""

# cattlepi section
mkdir -p ${SDROOT}/.cattlepi
BUILDERS_API_KEY=$(jq -r ".config.buildcontrol.builders_api_key" /tmp/current_config)

# inject our own ssh key
curl -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -H "X-Api-Key: $BUILDERS_API_KEY" \
    https://api.cattlepi.com/boot/default/config > ${SDROOT}/builder.config

ROUTE=$(ip route get 8.8.8.8)
IPV4=$(awk '{print $7}' <<< "${ROUTE}")
echo $IPV4
RASPBIAN_IMG="http://${IPV4}/2018-06-27-raspbian-stretch-lite.zip"
export RASPBIAN_IMG

BUILDCONTROL_SSH_KEY=$(head -1 /home/pi/.ssh/id_rsa.pub)
export BUILDCONTROL_SSH_KEY
PAYLOAD=$(cat ${SDROOT}/builder.config | jq '.config.ssh.pi.authorized_keys[1]=env.BUILDCONTROL_SSH_KEY' | jq '.config.standalone.raspbian_location=env.RASPBIAN_IMG')

curl -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -H "X-Api-Key: $BUILDERS_API_KEY" \
    -X POST -d "$PAYLOAD" \
    https://api.cattlepi.com/boot/default/config

# setup structures for controlling the builder pis
mkdir -p ${BUILDERSDIR}
BUILDERC=$(jq -r ".config.buildcontrol.build_machines | length" /tmp/current_config)
let BUILDERC=$((BUILDERC - 1))
for BUILDERI in `seq 0 $BUILDERC`
do
    CURRENT_BUILDER=$(jq -r '.config.buildcontrol.build_machines['$BUILDERI']' /tmp/current_config)
    echo "found builder ${CURRENT_BUILDER}"
    mkdir -p ${BUILDERSDIR}/${CURRENT_BUILDER}
done

for BUILDERI in $(ls -1 ${BUILDERSDIR})
do
    touch ${BUILDERSDIR}/${CURRENT_BUILDER}/state
done

# setup the structures for receiving work
mkdir -p ${WORKDIR}
mkdir -p ${WORKFLOWDIR}

cp -R ${SELFDIR}/* ${SDROOT}/
chmod +x ${SDROOT}/*.sh

sudo chown -R pi:pi ${SDROOT}