#!/bin/bash

MESSAGE="Installing the default settings for XEmacs"
DO_INSTALL=1

source "$HOME/.${USER}_config/base.sh"

if [ $1 -ne 1 ]; then
    echo "Would you like to install default settings for XEmacs? [Y/N]"
    
    read answer
    case $answer in
	y| Y | yes | Yes | YES) ;;
	*) DO_INSTALL=0 
    esac
fi

if [ $DO_INSTALL -eq 1 ]; then
    CWD=`pwd`
    UpdateFile $CWD/.dabbrev $HOME/.dabbrev $BACK_UP_DIR
    UpdateFile $CWD/.xemacs $HOME/.xemacs $BACK_UP_DIR

    # Make symlink to 'cedet' directory
    if [ -d "$HOME/cedet-1.0pre3" ]; then
        if [ ! -L "$HOME/.xemacs/lisp/cedet-1.0pre3" ]; then
            ln -s "$HOME/cedet-1.0pre3" "$HOME/.xemacs/lisp/cedet-1.0pre3"
        fi
    fi

    MESSAGE=$MESSAGE"\t[Done]"
    echo -e $MESSAGE
else
    echo "Not installing settings for Xemacs"
fi


