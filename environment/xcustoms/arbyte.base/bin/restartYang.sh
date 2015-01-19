#!/bin/bash

# Check if Yang is already running
if [[ -n $(fp 'python2.7 ./Yang/YangDbDealBooker.py') ]]; then
   printf "\nYang is already running. Not restarting.\n\n"
   exit 1
fi

binDir="${HOME}/live/bin"
outputFile=$(ls ${binDir} | grep '^output_')

if [[ -z ${outputFile} ]]; then
    printf "\n No output file found in ${binDir}\n"
    exit 1
elif [[ $(echo ${outputFile}|wc -w) -gt 1 ]]; then
    printf "\n Multiple output files found: \n${outputFile}\n Will not start Yang.\n"
    exit 1
fi

# Fetch the command for starting Yang
prefix='Starting Yang using command: ' 
command=$(grep "${prefix}" output_* | sed "s/${prefix}//")

# Start Yang
${command}
