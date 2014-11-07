#!/bin/bash

# On Monday, reset the sequence numbers for CME
if [[ $(date +%w) -eq 1 ]]; then
    rm -f ${logDir}/client.*.CME*
fi

