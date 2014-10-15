#!/bin/bash

MESSAGE="Installing the default settings for Emacs"
DO_INSTALL=1

CEDET="cedet-1.1"

source "$HOME/.${USER}_config/base.sh"

if [ $1 -ne 1 ]; then
    echo "Would you like to install default settings for Emacs? [Y/N]"
    
    read answer
    case $answer in
        y| Y | yes | Yes | YES) ;;
        *) DO_INSTALL=0 
    esac
fi

if [ $DO_INSTALL -eq 1 ]; then
    CWD=`pwd`
    UpdateFile $CWD/.emacs $HOME/.emacs
    UpdateFile $CWD/.emacs.d $HOME/.emacs.d

    MESSAGE=$MESSAGE"\t[Done]"
    echo -e $MESSAGE
else
    echo "Not installing settings for Emacs"
fi


# Build the 'cedet' package
echo "    Building the CEDET package"
cd $HOME/.emacs.d/lisp
answer='y'
if [ -d "$HOME/.emacs.d/lisp/${CEDET}" ]; then
    echo "Looks like CEDET is already built. Would you like to rebuild? [Y/N]"
    read answer
fi

case $answer in
    y| Y | yes | Yes | YES)
      tar -xzf "$CEDET".tar.gz > /dev/null 2>&1
      cd $HOME/.emacs.d/lisp/${CEDET}
      make EMACS=emacs # > /dev/null 2>&1
      echo "    Finished building the CEDET package";;
esac
