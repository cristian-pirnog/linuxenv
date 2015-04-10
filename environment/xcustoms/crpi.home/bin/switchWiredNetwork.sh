#!/bin/bash

#----------------------------------
# Functino printUsage
#----------------------------------
printUsage()
{
cat << %%USAGE%%
    Usage: `basename $0` [home|work]

    Description:
        Tool that switches the wired network configuration between office
	  and home set-ups.

    Argument:
        home
	    Switches to home set-up.

	work
	    Switches to work set-up.
%%USAGE%%
}


#=======================  Main script ============================

if [ $# -ne 1 ]; then
    printUsage
    exit 1
fi

setupType=${1}
connectionId=p2p1

# Check the input argument
if [[ ${setupType} != 'work' ]] && [[ ${setupType} != 'home' ]]; then
    printUsage
    exit 1
fi

configFile="${HOME}/.crpi_config/environment/xcustoms/crpi.${setupType}"/ifcfg-p2p1

if [[ ! -f ${configFile} ]]; then
    echo "Network config file not found: "${configFile}
    exit 1
fi

# Disconnect the wired connection
nmcli connection show active ${connectionId} >/dev/null 2>&1
wasConnected=!$?
if [[ ${wasConnected} -eq 1 ]]; then
    nmcli device disconnect ${connectionId}
fi

# Change the config file accordingly
sudo cp ${configFile} /etc/sysconfig/network-scripts/ || exit 1

# Disconnect the wireless
nmcli device disconnect wlp11s0

# Bring the wired connection back up
if [[ ${wasConnected} -eq 1 ]]; then
    nmcli con up ${connectionId}
else
    echo "Interface ${connectionId} was not connected"
fi
