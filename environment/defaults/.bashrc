# -*- mode: sh -*- #
# .bashrc

# Source .bashrc_default, if present
test -f $HOME/.bashrc_default && . $HOME/.bashrc_default

# For history search configuration, see file .inputrc

##
# User environment settings
##
# Default environment
if [ -f $HOME/.userenv ]; then
    . $HOME/.userenv
fi

# The custom environment
if [ -f $HOME/.userenv_custom ]; then
    . $HOME/.userenv_custom
else
    echo "File $HOME/.userenv_custom does not exist. Using default environment."
fi

##
# Last, source user aliases
##
test -f ~/.aliases && source ~/.aliases
test -f ~/.aliases_custom.base && source ~/.aliases_custom.base
test -f ~/.aliases_custom && source ~/.aliases_custom

# Set the file masks
umask 002
