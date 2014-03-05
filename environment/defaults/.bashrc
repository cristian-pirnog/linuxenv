# -*- mode: sh -*- #
# .bashrc

# Source .bashrc_default, if present
test -f $HOME/.bashrc_default && . $HOME/.bashrc_default


export PATH=/home/env/bin:$PATH

# For history search configuration, see file .inputrc

##
# User environment settings
##
# Default environment
if [ -f $HOME/.userenv ]; then
    . $HOME/.userenv
fi

# Source the custom software file
if [ -f $HOME/.software_custom ]; then
    . $HOME/.software_custom
else
    echo "File $HOME/.software_custom does not exist. No custom software will be available installed."
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
