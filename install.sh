# -*- mode: sh -*- #
#!/bin/bash

##
# Script that installs the environment for the current user
##

source "$HOME/.${USER}_config/base.sh"


# ----------------------------------------------
# Main script
# ----------------------------------------------
#

CWD=`pwd`
# The directory 'environment' is treated differently
ALL_DIRS=`find . -type d | grep -v '.git' | grep -v '^\.$' | grep '^\./environment' | sort`
ALL_DIRS=$ALL_DIRS" "`find . -type d | grep -v '.git' | grep -v '^\.$' | grep -v '^\./environment'`

myInstallScript="install.sh"
myConfigFile="config.install"

myOriginalDir=`pwd`
for myDir in $ALL_DIRS
do
  cd $myOriginalDir > /dev/null
  echo " "
  echo "---  Entering directory $myDir"
  echo "     Looking for config file: $myDir/$myConfigFile"
  # Perform the standard installation from the config file (if it exists)
  if [ -f "$myDir/$myConfigFile" ]; then
      echo "     Found config file: $myDir/$myConfigFile"
      MESSAGE="Making symlinks for: $myDir"
      InstallFromConfigFile "$myOriginalDir/$myDir" "$myConfigFile"
      MESSAGE=$MESSAGE"\t[Done]"
      echo -e $MESSAGE
  fi

  # Run the custom install script (if it exists)
  if [ -f $myDir/$myInstallScript ]; then
      echo "     Found install script: $myDir/$myInstallScript"
      cd $myDir
      source $myInstallScript
  fi
done

IFS=" "
# Change permissions to the '.ssh' configuration files
SSH_CONFIG_FILES="config known_hosts"
echo " "
echo "--- Setting permissions for files"
for myFile in $SSH_CONFIG_FILES
do
    # If the file is a symlink, 
    if [[ -L $HOME/.ssh/${myFile} ]]; then
	myTargetFile=$(ls -AFl $HOME/.ssh/${myFile} | awk '{print $NF}')
    else
	myTargetFile=${myFile}
    fi

    if [[ -f ${myTargetFile} ]]; then
        echo "     Permissions 600: ${myTargetFile}"
        chmod 600 ${myTargetFile}
    else
        echo "     Skipping file ${myTargetFile} (file not found)"
    fi
done

# Update the crontab, if a cron.$USER.tab exists
CRONTAB_FILE=$HOME/CRON/cron.${USER}.tab
if [ -f $CRONTAB_FILE ]; then
    echo "--- Updated cron jobs from file: $CRONTAB_FILE."
    crontab $CRONTAB_FILE
else
    echo "--- No crontab file ($CRONTAB_FILE) found. Will not update cron jobs."
fi

