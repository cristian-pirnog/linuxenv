#!/bin/bash

MESSAGE="Installing the default settings VI"
DO_INSTALL=1


source "$HOME/.${USER}_config/base.sh"

if [ $1 -ne 1 ]; then
    echo "Would you like to install default settings for VI? [Y/N]"
    
    read answer
    case $answer in
	y| Y | yes | Yes | YES) ;;
	*) DO_INSTALL=0
    esac
fi


if [ $DO_INSTALL -eq 1 ]; then
    CWD=`pwd`
    UpdateFile $CWD/.vim $HOME/.vim $BACK_UP_DIR
    UpdateFile $CWD/.vimrc $HOME/.vimrc $BACK_UP_DIR

    MESSAGE=$MESSAGE"\t\t[Done]"
    echo -e $MESSAGE
else
    echo "Not installing settings for VI"
fi
