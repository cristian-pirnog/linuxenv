##
# Function 'printErrorMessage'
##
printErrorMessage()
{
 echo Error processing file \'$1\'
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
        echo "        Skipping. Target directory doesn't exist: $TARGET_PATH"
        return 1
    fi

    # Only if a BACK_UP_DIR specified
    if [ ! -z $3 ]; then
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
    local DIR=$1
    local CONFIG_FILE=$2
    local BACK_UP_DIR="$HOME/.back-up"

    local ALL_CONFIGURATIONS=`cat $DIR/$CONFIG_FILE | grep -v '^#' | grep -v '^$'`

    echo "     ++ Installing from config file: $DIR/$CONFIG_FILE"

    # No Whitespace == Line Feed:Carriage Return
    No_WSP=$'\x0A'$'\x0D'
    IFS=$No_WSP
    for myConfig in $ALL_CONFIGURATIONS
      do
      eval SOURCE_FILE=`echo $myConfig | awk '{print $1}'`
      eval TARGET_FILE=`echo $myConfig | awk '{print $2}'`

      UpdateFile $DIR/$SOURCE_FILE $TARGET_FILE $BACK_UP_DIR
    done
}
