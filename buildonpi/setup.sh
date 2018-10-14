#!/bin/bash

# move tmp to sdcard (ln -s) and ensure right permissions
sudo mount /dev/mmcblk0p2 /sd
sudo rm -rf /sd/*
sudo chown pi:pi /sd

# install the needed packages
sudo apt-get install -y libffi-dev libssl-dev python-pip nginx
ufw allow http

# install virtualenv
sudo pip install virtualenv

# setup the environment vars
mkdir -p /sd/.aws
cat <<'EOF' > /sd/.aws/config
[default]
output = json
region = us-west-2
EOF

echo "[default]" > /sd/.aws/credentials
echo "aws_access_key_id = $(jq -r ".config.buildcontrol.aws_ak" /tmp/current_config)" >> /sd/.aws/credentials
echo "aws_secret_access_key = $(jq -r ".config.buildcontrol.aws_sk" /tmp/current_config)" >> /sd/.aws/credentials

# generate ssh keys
sudo rm -rf /home/pi/.ssh/id_*
su - pi -c "ssh-keygen -f /home/pi/.ssh/id_rsa -N '' -t rsa -b 4096 -C "hello@cattlepi.com""

# cattlepi section
mkdir -p /sd/.cattlepi
BUILDERS_API_KEY=$(jq -r ".config.buildcontrol.builders_api_key" /tmp/current_config)

# inject our own ssh key
curl -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -H "X-Api-Key: $BUILDERS_API_KEY" \
    https://api.cattlepi.com/boot/default/config > /sd/builder.config

BUILDCONTROL_SSH_KEY=$(head -1 /home/pi/.ssh/id_rsa.pub)
export BUILDCONTROL_SSH_KEY
PAYLOAD=$(cat /sd/builder.config | jq '.config.ssh.pi.authorized_keys[1]=env.BUILDCONTROL_SSH_KEY')

curl -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -H "X-Api-Key: $BUILDERS_API_KEY" \
    -X POST -d "$PAYLOAD" \
    https://api.cattlepi.com/boot/default/config

# setup structures for controlling the builder pis


sudo chown -R pi:pi /sd