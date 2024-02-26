#!/bin/bash

log_file="${HOME}/runPicframe.log"
echo "${0} started now $(date +%Y%m%d-%H%M%S)" >> ${log_file}

if [[ $(ps aux|grep python| grep picframe| grep -v grep) ]]; then
   echo "Picframe is already running. Exiting." >> ${log_file}
   exit 0
fi

> ${log_file}

code_dir=/home/pi/code/picframe
cd ${code_dir}
source build/bin/activate >> ${log_file} 2>&1
PYTHONPATH=${PYTHONPATH}:picframe python picframe/start.py ${HOME}/code/picframe/cristian_config/configuration.yaml  >> ${log_file} 2>&1

