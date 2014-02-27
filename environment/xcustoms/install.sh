#!/bin/bash

##
# Script that installs the environment for the current user
##
MY_DIR="`pwd`/$XCUSTOMS_USER"
myUserConfigFile="config.install.$XCUSTOMS_USER"

MY_FULL_FILE="$MY_DIR/$myUserConfigFile"

if [ -f $MY_FULL_FILE ]; then
    MESSAGE="Making symlinks for: $myDir"
    InstallFromConfigFile "$MY_DIR" "$myUserConfigFile"
    MESSAGE=$MESSAGE"\t[Done]"
    echo -e $MESSAGE
fi


# Run the custom install script (if it exists)
if [ -f $MY_DIR/$myInstallScript ]; then
    cd $MY_DIR
    source $myInstallScript
fi
