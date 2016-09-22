# -*- mode: sh -*- #
# .bashrc

# User specific environment and startup programs
export PATH=$HOME/bin:$PATH

# Source .bashrc_default, if present
test -f ${HOME}/.bashrc_default && . ${HOME}/.bashrc_default

# For history search configuration, see file .inputrc

##
# User environment settings
##
test -f ${HOME}/.userenv && source ${HOME}/.userenv
test -f ${HOME}/.userenv_custom.base && source ${HOME}/.userenv_custom.base
test -f ${HOME}/.userenv_custom && source ${HOME}/.userenv_custom

# Concatenate the default and user ssh config files into one
# This must be done after userenv_custom is sourced, since this file
# might make changes to the config.user file
cat ~/.ssh/config.base ~/.ssh/config.user > ~/.ssh/config

##
# Source user aliases
##
test -f ${HOME}/.aliases && source ${HOME}/.aliases
test -f ${HOME}/.aliases_custom.base && source ${HOME}/.aliases_custom.base
test -f ${HOME}/.aliases_custom && source ${HOME}/.aliases_custom

##
# And do stuff for completions
##
for f in ~/completions/*; do
    source $f
done


# Set the file masks
umask 002
