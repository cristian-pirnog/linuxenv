#!/bin/bash

echo " "
echo "Installing default settings for text editors"
echo "------------------------------------------------"

echo -e "\nWould you like to install default settings for text editors?[ (Y)es/(N)o/(A)ll]"
DO_INSTALL=1

read answer
case $answer in
    y | Y | yes | Yes | YES)
    NON_INTERACTIVE=0
    ;;
    a | A | all | All | ALL)
    NON_INTERACTIVE=1
    ;;
    *) DO_INSTALL=0
esac

if [ $DO_INSTALL -eq 1 ]; then
    cd vi
    source install.vi.sh $NON_INTERACTIVE
    cd - > /dev/null
    cd XEmacs
    source install.xemacs.sh $NON_INTERACTIVE
    cd - > /dev/null
    cd Emacs
    source install.emacs.sh $NON_INTERACTIVE
    cd - > /dev/null
else
    echo "Not installing text editors"
fi
echo "  "
