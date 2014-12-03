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

# The directory 'environment' is treated differently
ALL_DIRS=`find . -type d | grep -v '.git' | grep -v '^\.$' | grep '^\./environment' | sort`
ALL_DIRS=$ALL_DIRS" "`find . -type d | grep -v '.git' | grep -v '^\.$' | grep -v '^\./environment'`

INSTALL_SCRIPT="install.sh"
myConfigFile="config.install"

myOriginalDir=`pwd`

# Remove all symlinks that point to the current dir
cd ${HOME}
symlinksToRemove=$(ls -AFl | awk '{print $(NF-2), $NF}' | grep ${myOriginalDir} | awk '{print $1}')
test -n "${symlinksToRemove}" && rm ${symlinksToRemove}
cd $myOriginalDir

for myDir in $ALL_DIRS
do
  cd $myOriginalDir
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
  if [ -f $myDir/$INSTALL_SCRIPT ]; then
      echo "     Found install script: $myDir/$INSTALL_SCRIPT"
      cd $myDir
      source $INSTALL_SCRIPT
  fi
done

IFS=" "
# Change permissions to the '.ssh' configuration files
SSH_CONFIG_FILES="config known_hosts"
echo " "
echo "--- Setting permissions for sensitive files"
for myFile in ~/.ssh/config ~/.ssh/known_hosts ~/.netrc
do
    # If the file is a symlink, 
    if [[ -L ${myFile} ]]; then
	myTargetFile=$(ls -AFl ${myFile} | awk '{print $NF}')
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
CRONTAB_FILE=$HOME/CRON/cron.tab
if [ -f $CRONTAB_FILE ]; then
    echo "--- Updated cron jobs from file: $CRONTAB_FILE."
    crontab $CRONTAB_FILE
else
    echo "--- No crontab file ($CRONTAB_FILE) found."
    if [[ -n "$(crontab -l | grep -v '^#' | sed '/^ *$/d')" ]]; then
        print "\n\nFound scheduled cron jobs\n"
        echo "------------------------------------------"
        crontab-l
        echo "------------------------------------------"
        print "Would you like to remove them? [y/n] "
   
    read answer

    case $answer in
        y| Y | yes | Yes | YES)
            crontab -r
            ;;
        *)
            echo "Keeping CRON jobs"
            ;;
    esac
    fi
fi

