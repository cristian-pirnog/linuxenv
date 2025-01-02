#!/bin/bash

password_file=$(dirname $0)/mqtt_pwd

user_name=raspberry_pi_cron
password=$(cat ${password_file}) 

if [[ ! -f ${password_file} ]]; then
    echo "Couldn't find password file: ${password_file}"
    exit 1
fi

# The actual message is irrelevant, but we publish a JSON anyway
mosquitto_pub -h crpidiskstation -p 1883 -u ${user_name} -P ${password} -t shellies/livingroom/picframe/reload_model/set -m '{"set": true}'
