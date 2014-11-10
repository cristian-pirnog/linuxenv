#!/bin/bash

# On Monday, reset the sequence numbers for CME
if [[ $(date +%w) -eq 0 ]]; then
    rm -f ${logDir}/client.*.CME*
else
    echo "This script is supposed to run on Sunday"
fi

