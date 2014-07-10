#!/bin/bash

#----------------------------------------------
printUsage()
{
cat << %%USAGE%%
     Usage: $(basename ${0}) <-h|--help>
            $(basename ${0}) jobPrefix duration latestDate [earliestDate]

    Description:
       Manage (push/pop/etc.) stashes for all checked-out products.

    Arguments:
       jobPrefix

       duration
             One of: 6m, 3m

       latestDate
             The latest date of the simulations

       earliestDate
             The earliest date of the simulation. If not provided: takes 20120806.

    Options:
       -h
       --help
             Print this help message and exit.


%%USAGE%%
}


#-------------------------------------------
# Function generateRollingOpts
#-------------------------------------------
generateRollingOpts()
{
    local lPrefix=$1
    local lDuration=$2
    local lLatestDate=$3
    local lEarliestDate=$4
    
    ## Set the lDuration
    if [[ $lDuration == '3m' ]]; then
	shiftWeeks=13
    elif [[ $lDuration == '6m' ]]; then
	shiftWeeks=26
    else
	echo "Unsupported lDuration: " $lDuration
	return 1
    fi
    
    ## Set the lLatestDate (i.e. the latest date
    if [[ -z ${lLatestDate} ]]; then
	d=$(date --date 'last monday' +%Y%m%d)    
    else
	d=${lLatestDate}
    fi
    
    if [[ $(date --date ${d} +%u) -ne 1 ]]; then
	echo "Start date is not a monday, but " $(date --date ${d} +%A)
	return 1
    fi
    
    if [[ -z ${lEarliestDate} ]]; then
	lEarliestDate=20120806
    elif [[ $(date --date ${lEarliestDate} +%u > /dev/null ) ]]; then
	echo "Invalid date ${lEarliestDate}"
	return 1
    fi

    d=$(date --date "$d + 7 days" +%Y%m%d)
    while [[ $d -gt ${lEarliestDate} ]]; do 
	d=$(date --date "$d - 7 days" +%Y%m%d)
	echo $lPrefix $d `date --date "$d + ${shiftWeeks} weeks - 3 days" +%Y%m%d`
    done
    
}


#-------------------------------------------
# Main script
#-------------------------------------------

ARGS=$(getopt -o h -l "help" -n "$(basename ${0})" -- "$@")

# If wrong arguments, print usage and exit
if [[ $? -ne 0 ]]; then
    printUsage
    exit 1;
fi

eval set -- "$ARGS"

## Parse options
toExclude=""
while true; do
    case ${1} in
	-h|--help)
	    printUsage
	    exit 0
	    ;;
	--)
	    shift
	    break
	    ;;
	"")
	    # This is necessary for processing missing optional arguments 
	    shift
	    ;;
    esac
done


commands=$(generateRollingOpts "$@"|sort -r)
if [[ $? -ne 0 ]]; then
    echo "There was an error in generating the commands:"
    echo $commands
    exit 1
fi

totalJobs=0
while read -r line; do
    totalJobs=$((totalJobs+1))
done <<< "$commands"


# 
doneJobs=1
echo commands=${commands}
while read -r line; do
    echo -e "Runing job ${doneJobs}/${totalJobs}:\t" $line;
    $line
    doneJobs=$((doneJobs+1))
done <<< "$commands"
