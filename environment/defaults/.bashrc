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

##
# Last, source user aliases
##
test -f ${HOME}/.aliases && source ${HOME}/.aliases
test -f ${HOME}/.aliases_custom.base && source ${HOME}/.aliases_custom.base
test -f ${HOME}/.aliases_custom && source ${HOME}/.aliases_custom

# Set the file masks
umask 002
