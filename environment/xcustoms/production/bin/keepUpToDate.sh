#!/bin/bash

#----------------------------------------------
cleanupRepo()
{
    local lRepoDir=${1}
    if [[ ! -d ${lRepoDir} ]]; then
        echo "Repo dir ${lRepoDir} doesn't exist"
        return 1
    fi

    local lOldDir=$(pwd)
    cd ${lRepoDir}
    git checkout .
    if [[ -n $(git status --porcelain) ]]; then
	rm $(git status --porcelain | awk '{print $NF}')
    fi

    if [[ -n $(git status --porcelain) ]]; then
        echo "Repo ${lRepoDir} still has changes after cleaning"
        return 1
    fi

    cd ${lOldDir}
}


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
for d in $(listRepos); do cleanupRepo "${d}" || exit 1; done
pula >> ${logFile} 2>&1
buildall ron Release install >> ${logFile} 2>&1

# The production stuff
cd ~/production
for d in $(listRepos); do cleanupRepo "${d}" || exit 1; done
pwd >> ${logFile} 2>&1
pula >> ${logFile} 2>&1

# The user config stuff
cd ~/.${USER}_config
pwd >> ${logFile} 2>&1
pull >> ${logFile} 2>&1
./update_user --nopull --noask >> ${logFile} 2>&1

