#!/bin/bash

#----------------------------------------------
printUsage()
{
cat << %%USAGE%%
     Usage: $(basename ${0}) [configs]
            $(basename ${0}) -d date [configs]
	    $(basename ${0}) --from date --until date [configs]

    Description:
       Checks if there is need to roll in the next days.

    Arguments:
       configs (optional, default: /mnt/live.logs/)
           Performs the check for the given configs. If any of the configs is a
	   directory, it will use all *.cfg files in that directory.

    Options:
       -d date
           Same as --from date --until date.

       --from date
           Specifies the start of the period to check (default next business day).

       -until date
	   Specifies the end of the period to check (default 5 days after start date).

%%USAGE%%
} 

#----------------------------------------------
dateOfNextWeekDay()
{
    local lArgument=''
    if [[ -n ${1} ]]; then
	lArgument="-d ${1}"
    fi
    
    local lTodaysDay=$(date +%w ${lArgument})
    local lToday=$(date +%Y%m%d ${lArgument})
    lOffset=1
    if [[ ${lTodaysDay} == 5 ]]; then
	lOffset=3
    elif [[ ${lTodaysDay} == 6 ]]; then
	lOffset=2
    fi

    date +%Y%m%d -d "${lToday} + ""${lOffset} days"
}


#----------------------------------------------
getProducts()
{
    optimizer translate $@ | grep Instruments | sed 's/Instruments//'

}


#----------------------------------------------
# Main script
#----------------------------------------------
ARGS=$(getopt -o h -l "help,date:,from:,until:" -n "$(basename ${0})" -- "$@")

# If wrong arguments, print usage and exit
if [[ $? -ne 0 ]]; then
    printUsage
    exit 1;
fi

eval set -- "$ARGS"

## Parse options
fromDate=$(dateOfNextWeekDay)
untilDate=$(date +%Y%m%d -d "${fromDate} + 5 days")
while true; do
    case ${1} in
	-h|--help)
	    printUsage
	    exit 0
	    ;;
	--date)
	    fromDate=${2}
	    untilDate=${2}
	    shift 2
	    ;;
	--from)
	    fromDate=${2}
	    shift 2
	    ;;
	--until)
	    untilDate=${2}
	    shift 2
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

# Check that untilDate >= fromDate
if [[ ${fromDate} -gt ${untilDate} ]]; then
    echo "From date comes after to until date: ${fromDate} > ${untilDate}" 
    exit 1
fi

# Get the configs
configs="$@"

if [[ -z ${configs} ]]; then
    configs=/mnt/live.logs/$(ls /mnt/live.logs/ | grep '^20' | sort | tail -1)
fi

# Fetch all products from the configs
products=""
for config in ${configs}; do
    if [[ -d ${config} ]]; then
	for c in $(find ${config} -name '*.cfg'); do
	    products=${products}' '$(getProducts $c)
	done
    else
	products=${products}' '$(getProducts $config)
    fi
    # Make the products unique
    products=$(echo ${products} | tr -s [:space:] \\n | sort -u)
done

for p in ${products}; do
    rollDate=$(optimizer staticInfo ${p} ${fromDate} ${untilDate} | awk '{if($4 == 1) print $1}')
    if [[ -n ${rollDate} ]]; then
	message=${message}"
"$(printf "The product %s must be rolled on %s\n" $p $(dateOfNextWeekDay ${rollDate}))
    fi
done


CRISTIAN='pirnog@gmail.com'
GIULIANO='giuliano.tirenni@gmail.com'
JENS='jens.poepjes@gmail.com'
recipients="${CRISTIAN} ${GIULIANO} ${JENS}"

# If no products need rolling
subject="Must roll products"
if [[ -z ${message} ]]; then
    recipients="${CRISTIAN}"
    subject="No rolling necessary"
    message="None of the traded products needs rolling:
${products}" 
fi

# Send email
mail -s "${subject}" ${recipients} << EOF
   ${message}
EOF
