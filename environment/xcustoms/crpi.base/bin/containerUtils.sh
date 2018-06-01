#!/bin/bash

test -f ~/.userfunctions && source ~/.userfunctions

sudo='sudo'
if [[ $(whoami) == 'cristian' ]]; then
    sudo=''
fi

#----------------------------------------------
# Function upvar
#----------------------------------------------
# Assign variable one scope above the caller
# Usage: local "$1" && upvar $1 "value(s)"
# Param: $1  Variable name to assign value to
# Param: $*  Value(s) to assign.  If multiple values, an array is
#            assigned, otherwise a single value is assigned.
# NOTE: For assigning multiple variables, use 'upvars'.  Do NOT
#       use multiple 'upvar' calls, since one 'upvar' call might
#       reassign a variable to be used by another 'upvar' call.
# Example:
#
#    f() { local b; g b; echo $b; }
#    g() { local "$1" && upvar $1 bar; }
#    f  # Ok: b=bar
#
function upvar()
{
    if unset -v "$1"; then           # Unset & validate varname
        if (( $# == 2 )); then
            eval $1=\"\$2\"          # Return single value
        else
            eval $1=\(\"\${@:2}\"\)  # Return array
        fi
    fi
}

function getContainerId()
{
    local lName=${1}
    ${sudo} docker ps ${@:2} -q --filter name=${lName}
}

function selectContainerIds()
{
    local lFilter=${1}
    ${sudo} docker ps ${@:2} --filter name=${lFilter} --format '{{.ID}}'
}

function listContainerNames()
{
    local lFilter=${1}

    if [[ -n ${lFilter} ]]; then
	lFilter='--filter name='${lFilter}
    fi
    ${sudo} docker ps ${@:2} ${lFilter} --format '{{.Names}}'
}

getContainerEnvVariable()
{
    if [[ $# -ne 2 ]]; then
	echo "getContainerEnvVariable takes two arguments: containerId and variableName"
	exit 1
    fi

    local lContainerId=${1}
    local lVariableName=${2}

    # sed expression explained:
    #  [^=]*   match everything (ungreedy) until a '=' is found
    #  =       match the =
    ${sudo} docker exec ${lContainerId} env 2>/dev/null | grep ${lVariableName} | sed 's/[^=]*=//'
}


function selectContainer()
{
    if [[ $# -lt 2 ]]; then
	echo "selectContainer takes at least two arguments: variable names for containerId and imageName"
	exit 1
    fi

    local lKubePrefix='k8s_'
    local lFilter=${3}

    local lContainerNames=$(listContainerNames ${lFilter} ${@:4} | grep -v ${lKubePrefix}POD)
    imageCount=$(echo ${lContainerNames} | wc -w)
    case ${imageCount} in
	1)
            answer=1
	    ;;
	0)
	    exitWithError "No docker container found containing filter ${lFilter}."
	    ;;
	*)
            while true; do
		index=0
		for img in ${lContainerNames}; do
        	    index=$((index + 1))
        	    echo "[$index] " $img | sed "s/${lKubePrefix}//"
		done
		printf "\nChoose container (1 to %d, q to quit): " ${index}
		read answer

		if [[ ${answer} == 'q' ]]; then
                    exit 0
		fi

		if [[ ${answer} -gt 0 ]] && [[ ${answer} -le ${index} ]]; then
        	    break
		else
        	    printf "The choice must be a number between 1 and ${index}.\n\n"
		fi
            done
    esac
    local lContainerName=$(echo ${lContainerNames} | awk -v answer=${answer} '{print $answer}')

    local lContainerId=$(getContainerId ${lContainerName} ${@:4})
    if [[ $(echo ${lContainerId}|wc -w) -gt 1 ]]; then
        echo "Multiple container ids found for image ${lContainerName}"
	while true; do
            index=0
            for id in ${lContainerId}; do
        	    index=$((index + 1))
        	    echo "[$index] " $id
            done
            printf "\nChoose one (1 to %d, q to quit): " ${index}
            read answer

            if [[ ${answer} == 'q' ]]; then
                exit 0
            fi

            if [[ ${answer} -gt 0 ]] && [[ ${answer} -le ${index} ]]; then
        	    break
            else
        	    printf "The choice must be a number between 1 and ${index}.\n\n"
            fi
        done

        lContainerId=$(echo ${lContainerId} | awk -v answer=${answer} '{print $answer}')
    fi

    upvar ${1} ${lContainerId}
    upvar ${2} ${lContainerName}
}
