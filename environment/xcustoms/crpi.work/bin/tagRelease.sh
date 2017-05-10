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
        echo '--'$(sed 's/,/ --/g' <<< ${longOptions}) $(echo ${shortOptions} | \
            sed 's/[^:]/-& /g') 'major minor patch' | sed 's/://g' | tr ' ' '\n'
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

## Check that we're on the master branch
branch=$(br -ls | awk '{print $NF}')
if [[ ${branch} != master ]]; then
    exitWithError 'You can only create tags in the "master" branch.'
fi

## Check that the local repo is up to date with the origin
if [[ -z $(git status | grep 'Your branch is up-to-date') ]]; then
    exitWithError 'The local repo is not in sync with origin/master.'
fi

## Check that there are no changes in the local repo
if [[ -z $(git status | grep 'nothing to commit') ]]; then
    exitWithError 'There are changes in the local repo.'
fi

versionFile=.version
if [[ ! -f ${versionFile} ]]; then
    getAnswer "Could not find version file: ${versionFile}. Start with version 0.0.1?" || exit 0
    version='0.0.0'
else
    version=$(cat ${versionFile})
    if [[ ! ${version} =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
	exitWithError "Version ${version} is not of the form: X.Y.Z"
    fi
fi

## Get the version component to increment
versionComponent=${1}
case ${versionComponent} in
    major|M)
	newVersion=$(echo ${version} | awk -F '.' '{print ($1+1)"."0"."0}')
	;;
    minor|m)
	newVersion=$(echo ${version} | awk -F '.' '{print $1"."($2+1)"."0}')
	;;
    patch|p)
	newVersion=$(echo ${version} | awk -F '.' '{print $1"."$2"."($3+1)}')
	;;
    *)
	printUsage
	exit 1
	;;
esac

## Ask for confirmation
echo -e "\nPrevious version is ${version}. New version will be ${newVersion}."
getAnswer 'Continue?' || exit 0
echo ''


# Check that there is an entry in the CHANGELOG.md file for the new version
changelogFile=CHANGELOG.md
while true; do
if [[ ! -f ${changelogFile} ]] || \
       [[ -z $(grep "## \[${newVersion}\]" ${changelogFile}) ]]; then
    getAnswer "No entry for version ${newVersion} found in the ${changelogFile}. Would you like to add one now?" || exit 1
    ${EDITOR} ${changelogFile}
else
    sed -i "s/## \[${newVersion}\] - ReleaseDate/## [${newVersion}] $(date +%Y.%m.%d)/" ${changelogFile}
    break
fi
done

getAnswer "Tagged current checkout with version ${newVersion}. Would you like to push to the server?" || exit 1

echo ${newVersion} > ${versionFile} && \
    buildApidoc -f && \
    git add --all && \
    git commit -m "Updated version to ${newVersion}" && \
    git push

if [[ ! $? ]]; then
    echo "There was an error pushing the changes. Exiting"
    exit 1
fi

# Tag the relese and push it to the repo
git tag -a ${newVersion} -m "Version ${newVersion}" && \
    git push origin ${newVersion}
