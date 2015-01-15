#!/bin/bash

# Check if Yang is already running
if [[ -n $(fp 'python2.7 ./Yang/YangDbDealBooker.py') ]]; then
   printf "\nYang is already running. Not restarting.\n\n"
   exit 1
if

cd ~/live/bin
prefix='Starting Yang using command: ' 
command=$(grep "${prefix}" output_* | sed "s/${prefix}//")

${command}
