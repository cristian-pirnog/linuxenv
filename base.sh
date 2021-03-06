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
    # MUST KEEP SYNCHRONIZED WITH THE ONE FROM SaveCachedConfigValue
    local lCacheFile=$HOME/.${USER}_config/.config_cache

    # If no cache file, return
    if [[ ! -f ${lCacheFile} ]]; then return 1; fi
    grep "${1}" ${lCacheFile} | awk -F '=' '{print $NF}' | head -1
}

#----------------------------------------------
# Function SaveConfigValueToCache
#----------------------------------------------
SaveConfigValueToCache()
{
    # MUST KEEP SYNCHRONIZED WITH THE ONE FROM GetCachedConfigValue
    local lCacheFile=$HOME/.${USER}_config/.config_cache
    
    local lTag=${1}
    local lValue=${2}

    # If the value is empty, don't write it
    if [[ -z ${lValue} ]]; then return 1; fi

    # Remove the old entry in the cache file, if present...
    if [[ -f ${lCacheFile} ]]; then
        sed -i "/^${1}/d" ${lCacheFile}
    fi

    # ... and add the new one
    echo "${1}=${2}" >> ${lCacheFile}
}

#----------------------------------------------
# Function UpdateFile
#----------------------------------------------
# Arguments: $1 = SOURCE_FILE
#            $2 = DESTINATION_FILE
#            $3 = BACK_UP_DIR
#
UpdateFile()
{
    echo "        Making symlink $1 to $2"

    if [ ! -e $1 ]; then
        echo "Source file doesn't exist: ${1}" && return 0
    fi

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

    ln -sn $1 $2         # Make symbolic link to the SOURCE_FILE 
    if [ ! $? ] 
    then
        printErrorMessage $1
    fi
}


#----------------------------------------------
# Function 'InstallFromConfigFile'
#----------------------------------------------
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

      if [[ ${SOURCE_FILE} = /* ]]; then
          UpdateFile $SOURCE_FILE $TARGET_FILE ${lBackUpDir}
      else
          UpdateFile $lDir/$SOURCE_FILE $TARGET_FILE ${lBackUpDir}
      fi
    done
}

#----------------------------------------------
# Function AskForValue
#----------------------------------------------
# Arguments: $1 = Question
#            $2 = Variable to write into
#
#
AskForValue()
{
    local lQuestion="${1}"

    if [[ ${noAsk} = false ]]; then
	printf "${lQuestion}"
	local lAnswer && read lAnswer
	if [[ -n ${lAnswer} ]]; then
	    local "$2" && upvar $2 ${lAnswer}
	fi
    fi
}

#----------------------------------------------
# Function AskForValueInList
#----------------------------------------------
# Arguments: $1 = Question
#            $2 = Variable to write into
#
AskForValueInList()
{
    local lQuestion="${1}"
    local lDefaultValue="${2}"
    local lList=("${@:3}")

    if [[ ${noAsk} = false ]]; then
	while true; do
	    echo "Options:"
	    echo ${lList[@]} | tr ' ' '\n' | awk '{print "  "$0}'
	    printf "${lQuestion}: "
	    local lAnswer && read lAnswer
	    
	    if [[ -z ${lAnswer} ]] && [[ -n ${lDefaultValue} ]]; then
		eval 'lAnswer=${'$2'}'
	    fi
	    
	    for i in $(seq 0 ${#lList[@]}); do
		if [[ ${lList[$i]} = ${lAnswer} ]]; then
    		    local "$2" && upvar $2 ${lAnswer}
		    return
		fi
	    done

	    lQuestion="Value '${lAnswer}' is not in the list. Choose again"
	done
    fi
}
