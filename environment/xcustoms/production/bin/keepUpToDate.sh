#!/bin/bash

source ~/.bash_profile
mkdir -p ~/log
logDir=${HOME}/log/
logFile="${logDir}/keepUpToDate.$(date +%Y%m%d-%H%M%S).log"

# Clean-up old log files
find ${logDir} -type f -mtime +3 -exec rm {} \;

# The code
cd ~/code 
pwd >> ${logFile} 2>&1
branch -s master >> ${logFile} 2>&1
pula >> ${logFile} 2>&1
buildall ron Release install >> ${logFile} 2>&1

# The production stuff
cd ~/production
pwd >> ${logFile} 2>&1
pula >> ${logFile} 2>&1

# The user config stuff
cd ~/.${USER}_config
pwd >> ${logFile} 2>&1
pull >> ${logFile} 2>&1
./updateuser --nopull --noask >> ${logFile} 2>&1

