#!/bin/bash

echo " "
echo "Installing default settings for text editors"
echo "------------------------------------------------"

INSTALL_EDITORS=$(GetCachedConfigValue INSTALL_EDITORS)
INSTALL_ALL_EDITORS=$(GetCachedConfigValue INSTALL_ALL_EDITORS)
if [[ -z ${INSTALL_EDITORS} ]] && [[ -z ${INSTALL_ALL_EDITORS} ]]; then
    printf  "\nWould you like to install default settings for text editors? [(Y)es/(N)o/(A)ll] "

    read answer
    case $answer in
	y | Y | yes | Yes | YES)
	    INSTALL_EDITORS=1
	    INSTALL_ALL_EDITORS=0
	    ;;
	a | A | all | All | ALL)
	    INSTALL_ALL_EDITORS=1
	    ;;
	*) INSTALL_EDITORS=0
    esac
fi

SaveConfigValueToCache INSTALL_EDITORS ${INSTALL_EDITORS}
SaveConfigValueToCache INSTALL_ALL_EDITORS ${INSTALL_ALL_EDITORS}

CEDET="cedet-1.1"
if [ ${INSTALL_EDITORS} -eq 1 ]; then
    cd vi
    source install.vi.sh $INSTALL_ALL_EDITORS
    cd - > /dev/null
    cd XEmacs
    source install.xemacs.sh $INSTALL_ALL_EDITORS ${CEDET}
    cd - > /dev/null
    cd Emacs
    source install.emacs.sh $INSTALL_ALL_EDITORS ${CEDET}
    cd - > /dev/null
else
    echo "Not installing text editors"
fi
echo "  "
