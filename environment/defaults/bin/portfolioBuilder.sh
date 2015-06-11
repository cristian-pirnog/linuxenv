#!/bin/bash

#----------------------------------------------
printUsage()
{
cat << %%USAGE%%
     Usage: $(basename ${0}) [-h]
            $(basename ${0}) <-b|--branch> <index|nonindex> p1 p2 p3...

    Description:
       Run the portfolio builder for the given policies.

    Arguments:
       p1 ... pn
             The id\'s of the policies to build (usually numbers).
    Options:
       -h
       --help
             Print this help message and exit.

       -b name
       --branch name
             Uses the branch with the provided name
%%USAGE%%
}

#----------------------------------------------
# Main script
#----------------------------------------------
ARGS=$(getopt -o hb: -l "help,branch:," -n "$(basename ${0})" -- "$@")

# If wrong arguments, print usage and exit
if [[ $? -ne 0 ]]; then
    printUsage
    exit 1;
fi

eval set -- "$ARGS"

## Parse options
toExclude=""
branch=""
while true; do
    case ${1} in
	-h|--help)
	    printUsage
	    exit 0
	    ;;
	-b|--branch)
	    branch="${2}"
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

# Fetch the input arguments
assetClass=$1
shift
policyNos=$@

if [[ -n ${branch} ]]; then
    echo "Using branch: ${branch}"
    cmd="runPy -b ${branch}"
else
    cmd="runPy"
fi

if [[ ${assetClass} != 'index' ]] && [[ ${assetClass} != 'nonindex' ]]; then
    printf '\nUnsupported asset class: %s\n\n'  "${assetClass}"
    exit 1
fi

${cmd} -- createTotal ${assetClass} -s 0 || exit 1
${cmd} -- runPortfolios ${assetClass} -l ${policyNos} --export || exit 1

for n in ${policyNos}; do
    cd ${assetClass}/PortfolioPolicies/Policy${n}* || exit 1

    echo "Running $(basename $(pwd))"

    # Create the jobs file
    ${cmd} -- runCreateJobsOS --local -n 6 -v || exit 1
    
    jobsFileName=jobOS.sh
    if [[ ! -f ${jobsFileName} ]]; then
	printf '\n\nCould not find jobs file %s/%s' $(pwd) ${jobsFileName}
	continue
    fi

    # Add the runPy prefix
    jobFile=$(cat ${jobsFileName} | awk '{print $2}')
    awk -v c="${cmd}" '{if (NR==2) {print c" -- "$0;} else {print $0}}' ${jobFile} > ${jobFile}.new && mv ${jobFile}.new ${jobFile} || exit 1
    
    # Run the OOS sims
    ./${jobsFileName} || exit 1

    cd - >/dev/null
done
