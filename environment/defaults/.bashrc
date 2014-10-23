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
if [ -f $HOME/.aliases ]; then
    . $HOME/.aliases
fi


# The custom aliases
if [ -f ~/.aliases_custom ]; then
    . ~/.aliases_custom
fi

# Set the file masks
umask 002
