#!/bin/bash

source ~/bin/commons.sh

#-----------------------------------
# Procedure ListCommitInfo
#-----------------------------------
GetCommiter()
{
    local MyRevision=$1
    svn log -c"$MyRevision" | grep '^r[0-9]* |' | awk -F '|' '{print $2}'
}


#-----------------------------------
# Procedure ListCommitInfo
#-----------------------------------
ListCommitInfo()
{
    local MyRevisions=$1
    for Rev in $MyRevisions
    do 
	MyCommiter=`GetCommiter $Rev`
	echo "Revision $Rev --> $MyCommiter"
	echo "------------------------------------------"
	echo "Changed files:"
	svn diff -c"$Rev" --summarize
	echo "---"
	echo "Log: "
	svn log -r"$Rev" | grep -v -e "----" | grep -v '^r' | grep -v "^$"
	echo " "
	echo "=========================================="
    done
}


#-----------------------------------
# Procedure GetEmails
#-----------------------------------
GetEmails()
{
    local MyRevisions=$1
    local MyCommiters=""
    for Rev in $MyRevisions
    do 
	MyCommiters="$MyCommiters\n"`GetCommiter $Rev`
    done

    MyCommiters=`echo -e "$MyCommiters" | sort | uniq`
    echo $MyCommiters | sed 's/\([a-z]*\)/\1@imc.nl/g'
}



if [ $# -eq 1 ];
then
    MyCommand='echo'
else
    MyCommand='SendEMail'
fi


MyToday=`date +%Y-%m-%d --date=today`
MyYesterday=`date +%Y-%m-%d --date=yesterday `


cd $MATLAB_STABLE_BRANCH

## Update the local checkout
svn update

## Retrieve the list of commits
MyRevisions=`svn log -r{$MyYesterday}:{$MyToday} | grep '^r[0-9]* |' | awk -F '|' '{print $1}' | replacestr 'r' ''`

MyEMailBody=`ListCommitInfo "$MyRevisions"`
Recipients=`GetEmails "$MyRevisions"`

MyEMailBody="People that have commited yesterday: $Recipients

$MyEMailBody"

IFS=$
$MyCommand "Changes done on $MyYesterday to $MATLAB_STABLE_BRANCH" "$MyEMailBody" "crpi@imc.nl"
