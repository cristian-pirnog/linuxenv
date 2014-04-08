#!/bin/bash

echo $(basename $0) > /home/crpi/bla.txt

if [[ ! -d '/media/truecrypt1/Dropbox' ]]; then
    echo "`date` - No dropbox folder found" >> /home/crpi/dropbox.errors
    exit 1
fi

dropbox running
result=$?
if [[ ${result} == 0 ]]; then
    echo "Starting dropbox" >> /home/crpi/bla.txt
    dropbox start
fi
