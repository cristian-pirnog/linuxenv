#!/bin/bash

LinkStandardFile()
{
    local lFileName=${1}

    if [[ ! -f ${lFileName} ]]; then
	touch ${lFileName}
    fi

    ln -sfn ${lFileName} ${HOME}
}



#----------------------------------------------
# Script that installs the environment for the current user
#----------------------------------------------
InstallFromDir()
{
    local lDirName="${1}"
    local lUserConfigFile="user.config.install" #${XCUSTOMS_USER}"
    local lFullFileName="$lDirName/$lUserConfigFile"

    if [[ -f ${lFullFileName} ]]; then
	printf "Making symlinks for: %s\n" "${lDirName}"
	InstallFromConfigFile "${lDirName}" "${lUserConfigFile}"
	printf "\t[Done]\n"
    else
	printf "Could not find config file: ${lFullFileName}\n"
    fi

    # Run the custom install script (if it exists)
    if [[ -f ${lDirName}/${INSTALL_SCRIPT} ]]; then
	cd $lDirName
	source $INSTALL_SCRIPT
    fi
}

## Main script

# Default values
userBaseDir="${XCUSTOMS_USER}.base"
userCustomDir=${XCUSTOMS_USER}

# Find if there are more directories for the user
userDirs=$(ls | grep "${XCUSTOMS_USER}" | grep -v "${userBaseDir}")
if [[ $(echo ${userDirs} | wc -w) -gt 1 ]]; then
    defaultCustomDir=$(GetCachedConfigValue DEFAULT_CUSTOM_DIR)

    message="Choose which to install"
    if [[ -n ${defaultCustomDir} ]]; then
	userCustomDir=${defaultCustomDir}
	message=${message}" (default ${defaultCustomDir})"
    fi

    echo ""
    AskForValueInList "${message}" userCustomDir ${userDirs}
elif [[ $(echo ${userDirs} | wc -w) -eq 1 ]]; then
    userCustomDir=${userDirs}
fi
SaveConfigValueToCache DEFAULT_CUSTOM_DIR ${userCustomDir}


# Install for the base dir
if [[ -d ${userBaseDir} ]]; then
    echo "+++ Installing from base dir ${userBaseDir}"
    fullDir=$(pwd)/${userBaseDir}
    InstallFromDir ${fullDir}

    LinkStandardFile ${fullDir}/.userenv_custom.base
    LinkStandardFile ${fullDir}/.aliases_custom.base
else
    echo "+++ Base dir not found ${userBaseDir}"
fi


# Install for the custom dir
fullDir=$(pwd)/${userCustomDir}
InstallFromDir ${fullDir}

LinkStandardFile ${fullDir}/.userenv_custom
LinkStandardFile ${fullDir}/.aliases_custom
