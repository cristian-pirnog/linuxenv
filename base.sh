##
# Function 'printErrorMessage'
##
printErrorMessage()
{
 echo Error processing file \'$1\'
}


#----------------------------------------------
# Function GetCachedConfigValue
#----------------------------------------------
GetCachedConfigValue()
{
    if [[ ! -f $HOME/.${USER}_config/.config_cache ]]; then return 1; fi
    grep "${1}" $HOME/.${USER}_config/.config_cache | awk -F '=' '{print $NF}' | head -1
}

#----------------------------------------------
# Function SaveConfigValueToCache
#----------------------------------------------
SaveConfigValueToCache()
{
    if [[ -f $HOME/.${USER}_config/.config_cache ]]; then
	sed -i "/^${1}/d" $HOME/.${USER}_config/.config_cache
    fi

    echo "${1}=${2}" >> $HOME/.${USER}_config/.config_cache
}

##
# Function 'UpdateFile'
##
# Arguments: $1 = SOURCE_FILE
#            $2 = DESTINATION_FILE
#            $3 = BACK_UP_DIR
#
UpdateFile()
{
    if [ ! -e $1 ]; then
	return 0;
    fi

    echo "        Making symlink $1 to $2"

    # Take action only if the target dir of the symlink exists
    TARGET_PATH=`GetFilePath $2` 
    if [ ! -d $TARGET_PATH ]; then
        echo "        Creating target directory: $TARGET_PATH"
        mkdir -p ${TARGET_PATH} || (echo "        Failed to create directory" && exit 1)
    fi

    # Only if a BACK_UP_DIR specified
    if [[ -n $3 ]]; then
	mkdir -p $3
    	rm -rf $3/`basename $2` > /dev/null 2>&1      # Remove the old back-up file
    	cp -rL $2 $3  > /dev/null 2>&1  # Copy the current file to back-up directory
    fi
    
    rm -rf $2 > /dev/null 2>&1      # Remove the current file

    ln -s $1 $2         # Make symbolic link to the SOURCE_FILE 
    if [ ! $? ] 
    then
        printErrorMessage $1
    fi
}


##
# Function 'InstallFromConfigFile'
##
# Arguments: $1 = SOURCE_DIR
#            $2 = CONFIG_FILE
#
InstallFromConfigFile()
{
    local lDir=${1}
    local lConfigFile=${2}
    local lBackUpDir="$HOME/.back-up"

    local lAllConfigurations=`cat $lDir/$lConfigFile | grep -v '^#' | grep -v '^$'`

    echo "     ++ Installing from config file: $lDir/$lConfigFile"

    # No Whitespace == Line Feed:Carriage Return
    No_WSP=$'\x0A'$'\x0D'
    IFS=$No_WSP
    for myConfig in $lAllConfigurations
      do
      eval SOURCE_FILE=`echo $myConfig | awk '{print $1}'`
      eval TARGET_FILE=`echo $myConfig | awk '{print $2}'`

      UpdateFile $lDir/$SOURCE_FILE $TARGET_FILE ${lBackUpDir}
    done
}
