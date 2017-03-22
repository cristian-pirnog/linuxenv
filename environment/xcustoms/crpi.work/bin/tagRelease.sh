#!/bin/bash

#----------------------------------------------
printUsage()
{
cat << %%USAGE%%
     Usage: $(basename ${0}) -h
            $(basename ${0}) [major|minor|patch]

    Description:
        Tags the current checkout to the next release number, using
	semantic versioning.
	
    Options:
       -h
       --help
             Print this help message and exit.

    Arguments:
       [major|minor|patch]
	     The version to increment.

%%USAGE%%
}


#----------------------------------------------
# Main script
#----------------------------------------------
shortOptions='h'  # Add short options here
longOptions='help,listOptions' # Add long options here
if $(isMac); then
    ARGS=`getopt "${shortOptions}" $*`
else
    ARGS=$(getopt -u -o "${shortOptions}" -l "${longOptions}" -n "$(basename ${0})" -- "$@")

fi

# If wrong arguments, print usage and exit
if [[ $? -ne 0 ]]; then
    printUsage
    exit 1;
fi

eval set -- "$ARGS"

while true; do
    case ${1} in
    --listOptions)
        echo '--'$(sed 's/,/ --/g' <<< ${longOptions}) $(echo ${shortOptions} | 
            sed 's/[^:]/-& /g') | sed 's/://g'
        exit 0
        ;;
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

if [[ $# -lt 1 ]]; then
    printUsage
    exit 1
fi

# Uncomment this for enabling debugging
# set -x

source ~/.userfunctions

versionFile=.version
if [[ ! -f ${versionFile} ]]; then
    exitWithError 'Could not find version file: '${versionFile}
fi

version=$(cat ${versionFile})
if [[ ! ${version} =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    exitWithError "Version ${version} is not of the form: X.Y.Z"
fi

# Get the version component to increment
versionComponent=${1}
case ${versionComponent} in
    major|M)
	newVersion=$(echo ${version} | awk -F '.' '{print ($1+1)"."0"."0}')
	;;
    minor|m)
	newVersion=$(echo ${version} | awk -F '.' '{print $1"."(2+1)"."0}')
	;;
    patch|p)
	newVersion=$(echo ${version} | awk -F '.' '{print $1"."$2"."($3+1)}')
	;;
    *)
	printUsage
	exit 1
	;;
esac


echo -e "\nPrevious version is ${version}. New version will be ${newVersion}."
getAnswer Continue? || exit 0
echo ''

git tag -a ${newVersion} -m 'Version ${newVersion}' && \
    echo ${newVersion} > ${versionFile} && \
    git add ${versionFile} && \
    git cmt 'updated version file'

echo "Tagged current checkout with version ${newVersion}. To push to the server run: "
echo -e "\t\tgit push origin ${newVersion}"
