#!/bin/bash
export RASPBIAN_LOCATION=http://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2018-06-29/2018-06-27-raspbian-stretch-lite.zip
export RASPBIAN_FILE=2018-06-27-raspbian-stretch-lite.zip

export GITHUB_API_USER=$(jq -r ".config.buildcontrol.gh_user" /tmp/current_config)
export GITHUB_API_TOKEN=$(jq -r ".config.buildcontrol.gh_token" /tmp/current_config)