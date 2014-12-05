#!/bin/bash

MESSAGE="Installing the default settings VI"
INSTALL_VI=$(GetCachedConfigValue INSTALL_VI)

source "$HOME/.${USER}_config/base.sh"

if [[ ${1} -ne 1 ]]; then
    if [[ -z ${INSTALL_VI} ]]; then
	printf "Would you like to install default settings for VI? [Y/N] "
	read answer
	case $answer in
	    y| Y | yes | Yes | YES)
		INSTALL_VI=1
		;;
	    *) 
		INSTALL_VI=0
		;;
	esac
    fi
SaveConfigValueToCache INSTALL_VI ${INSTALL_VI}
else
   INSTALL_VI=1
fi

if [[ ${INSTALL_VI} -eq 1 ]]; then
    CWD=`pwd`
    UpdateFile $CWD/.vim $HOME/.vim $BACK_UP_DIR
    UpdateFile $CWD/.vimrc $HOME/.vimrc $BACK_UP_DIR

    MESSAGE=$MESSAGE"\t\t[Done]"
    echo -e $MESSAGE
else
    echo "Not installing settings for VI"
fi
