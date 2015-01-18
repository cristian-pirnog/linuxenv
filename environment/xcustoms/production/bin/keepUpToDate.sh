#!/bin/bash

source ~/.bash_profile
mkdir -p ~/log
logFile="${HOME}/log/keepUpToDate.$(date +%Y%m%d-%H%M%S).log"

# The code
cd ~/code 
pula >> ${logFile} 2>&1
buildall ron Release install >> ${logFile} 2>&1

# The production stuff
cd ~/production
pula >> ${logFile} 2>&1

