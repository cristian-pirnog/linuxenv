#!/bin/bash

user_name=local_subscriber
password=$(grep ${user_name} /etc/mosquitto/conf.d/passwords | awk '{print $NF}') 

if [[ -z ${password} ]]; then
    echo "Couldn't find password for Mosquitto user ${user_name}"
    exit 1
fi


mosquitto_pub -h localhost -u ${user_name} -P ${password} -t homeassistant/switch/picframe_reload_model/set -m '{"set": true}'
