#!/bin/bash

MESSAGE="Installing the default settings for XEmacs"
INSTALL_XEMACS=1

INSTALL_ALL=${1}
CEDET=${2}

source "$HOME/.${USER}_config/base.sh"

if [[ ${INSTALL_ALL} -ne 1 ]]; then
    if [[ -z ${INSTALL_XEMACS} ]]; then
	printf "Would you like to install default settings for Emacs? [Y/N] "
	read answer
	
	case $answer in
            y| Y | yes | Yes | YES)
		INSTALL_XEMACS=1
		;;
            *) 
		INSTALL_XEMACS=0
		;;
	esac
    else
	INSTALL_XEMACS=1
    fi
fi
SaveConfigValueToCache INSTALL_XEMACS ${INSTALL_XEMACS}

if [[ ${INSTALL_XEMACS} -eq 1 ]]; then
    CWD=`pwd`
    UpdateFile $CWD/.dabbrev $HOME/.dabbrev $BACK_UP_DIR
    UpdateFile $CWD/.xemacs $HOME/.xemacs $BACK_UP_DIR

    echo "        Not installing CEDET (not supported for XEmacs)"

#    # Make symlink to 'cedet' directory
#    if [ -d "$HOME/cedet-1.0pre3" ]; then
#        if [ ! -L "$HOME/.xemacs/lisp/cedet-1.0pre3" ]; then
#            ln -s "$HOME/cedet-1.0pre3" "$HOME/.xemacs/lisp/cedet-1.0pre3"
#        fi
#    fi

    MESSAGE=$MESSAGE"\t[Done]"
    echo -e $MESSAGE
else
    echo "Not installing settings for Xemacs"
fi


