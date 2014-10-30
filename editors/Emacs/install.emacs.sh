#!/bin/bash

MESSAGE="Installing the default settings for Emacs"
INSTALL_EMACS=$(GetCachedConfigValue INSTALL_EMACS)

INSTALL_ALL=${1}
CEDET=${2}

source "$HOME/.${USER}_config/base.sh"

if [[ ${INSTALL_ALL} -ne 1 ]]; then
    if [[ -z ${INSTALL_EMACS} ]]; then
	printf "Would you like to install default settings for Emacs? [Y/N] "
	read answer
	
	case $answer in
            y| Y | yes | Yes | YES)
		INSTALL_EMACS=1
		;;
            *) 
		INSTALL_EMACS=0
		;;
	esac
    else
	INSTALL_EMACS=1
    fi
fi
SaveConfigValueToCache INSTALL_EMACS ${INSTALL_EMACS}

if [ ${INSTALL_EMACS} -eq 1 ]; then
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
answer=yes
if [ -d "${CEDET}" ]; then
    printf "Looks like CEDET is already built. Would you like to rebuild? [Y/N] "
    read answer
fi

case $answer in
	y| Y | yes | Yes | YES)
        pwd; ls
        tar -xzf "${CEDET}".tar.gz #> /dev/null 2>&1
    	cd ${CEDET}
    	make EMACS=emacs # > /dev/null 2>&1
    	echo "    Finished building the CEDET package"
    ;;
esac
