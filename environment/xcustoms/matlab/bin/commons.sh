#!/bin/bash

# This file contains variables and functions that are common to all
# of the scripts in this directory.
#
#

source ~/bin/database.sh

# The name of the responsible for the weekly merge
RESPONSIBLE_FOR_WEEKLY_MERGE="crpi"

# The readable TimeStamp
TIME_STAMP=`date +%a' '%b' '%e' '%H:%M:%S' '%Y`

# The UnixTimestamp
UNIX_TIME_STAMP=`date +%s000`



#-----------------------------------------
#
# Procedure GetLatestProductionBranch
#
#
#-----------------------------------------
GetLatestProductionBranch()
{
    local mySQLStatement="SELECT name_ FROM svnBranches_ WHERE type_ = 'PRODUCTION' and status_ = 'ACTIVE' ORDER BY id_ DESC LIMIT 1;"
    ExecuteSqlStatement "$mySQLStatement" "$DATABASE_COMMAND"
}

# Hard-code the name of the current stable branch (must be after GetLatestProductionBranch)
STABLE_BRANCH=`GetLatestProductionBranch`


#-----------------------------------------
#
# Procedure GetAllProductionBranches
#
#
#-----------------------------------------
GetAllProductionBranches()
{
    local mySQLStatement="SELECT name_ FROM svnBranches_ WHERE type_ = 'PRODUCTION' ORDER BY id_ DESC;"
    echo "$mySQLStatement" | $DATABASE_COMMAND | grep -v 'name_'
}



#-----------------------------------------
#
# Procedure GetLatestSVNRevision
#
#
#-----------------------------------------
GetLatestSVNRevision()
{
    echo `svn info svn+ssh://$RESPONSIBLE_FOR_WEEKLY_MERGE@repository_sag/home/repository/svn | grep Revision | replacestr 'Revision: ' ''`
}



#-----------------------------------------
#
# Procedure GetMainBranchUrl
#
#-----------------------------------------
GetMainBranchUrl()
{
    local mySQLStatement="select url_ as '' from svnBranches_ WHERE name_ = 'main';"

    ExecuteSqlStatement "$mySQLStatement" "$DATABASE_COMMAND"
}


#-----------------------------------------
#
# Procedure GetNewerResearchBranchesUrl
#
# Arguments: $1 = myCurrentProductionBranch
#
#-----------------------------------------
GetNewerResearchBranchesUrl()
{
    local myCurrentProductionBranch=$1

    local mySQLStatement="SELECT created_ as '' from svnBranches_ WHERE name_ = '$myCurrentProductionBranch'"
    local myRevisionNumber=`ExecuteSqlStatement "$mySQLStatement" "$DATABASE_COMMAND"`

    local mySQLStatement="SELECT url_ as '' from svnBranches_ WHERE type_ = 'PRODUCTION' AND status_ NOT IN ('COMPLETED', 'CLOSED') AND created_ > $myRevisionNumber;"

    ExecuteSqlStatement "$mySQLStatement" "$DATABASE_COMMAND"
}



#-----------------------------------------
#
# Procedure GetAllActiveResearchBranchUrls
#
# Arguments: $1 = originBranch
#
#-----------------------------------------
GetAllActiveResearchBranchUrls()
{
    local myOrigin=$1
    local mySQLStatement="select url_ as '' from svnBranches_ WHERE origin_ in (select id_ from svnBranches_ where name_ in ('$myOrigin', 'main')) AND deleted_ IS NULL AND status_ = 'ACTIVE' AND type_ = 'RESEARCH'"

    echo "$mySQLStatement" | $DATABASE_COMMAND
}



#-----------------------------------------
#
# Procedure GetResearchBranchesToMerge
#
# Arguments: $1 = originBranch
#
#-----------------------------------------
GetResearchBranchesToMerge()
{
    local myOrigin=$1
    local mySQLStatement="select url_ as '' from svnBranches_ WHERE origin_ in (select id_ from svnBranches_ where name_ in ('$myOrigin', 'main')) AND deleted_ IS NULL AND status_ = 'ACTIVE' AND type_ IN ('RESEARCH', 'BUG_FIX') AND keepSyncrhonized_ = TRUE;"

    echo "$mySQLStatement" | $DATABASE_COMMAND
}



#-----------------------------------------
#
# Procedure GetLatestMergeRevision
#
# Arguments: $1 = originBranch
#            $2 = targetBranch
#
#-----------------------------------------
GetLatestMergeRevision()
{

    local myOriginBranch=$1
    local myTargetBranch=$2

    local myOriginId=`GetActiveBranchId "$myOriginBranch"`
    local myTargetId=`GetActiveBranchId "$myTargetBranch"`
    
    local mySQLStatement="select max(toRevision_) from svnMerges_ where origin_ = $myOriginId and target_ = $myTargetId"
    ExecuteSqlStatement "$mySQLStatement" "$DATABASE_COMMAND"
}


#-----------------------------------------
#
# Procedure GetActiveBranchId
#
# Arguments: $1 = branchName
#
#-----------------------------------------
GetActiveBranchId()
{
    # Parse input arguments
    local myBranchName=$1

    local mySQLStatement="select id_ from svnBranches_ where name_ = \"$myBranchName\" AND deleted_ IS NULL"
    ExecuteSqlStatement "$mySQLStatement" "$DATABASE_COMMAND"
}





#-----------------------------------------
#
# Procedure GetLatestMergeRevisionEver
#
# Arguments: $1 = targetBranch
#
#-----------------------------------------
GetLatestMergeRevisionEver()
{

    local myTargetBranch=$1
    local myTargetBranchId=`GetActiveBranchId $myTargetBranch`
    local mySQLStatement="select max(toRevision_) from svnMerges_ where target_ = \"$myTargetBranchId\""
    
    ExecuteSqlStatement "$mySQLStatement" "$DATABASE_COMMAND"
}


#-----------------------------------------
#
# Procedure GetResponsibleForBranch
#
# Arguments: $1 = branchName
#
#-----------------------------------------
GetResponsibleForBranch()
{

    local myBranch=$1
    local mySQLStatement="SELECT responsible_ FROM svnBranches_ WHERE name_ = \"$myBranch\" AND deleted_ IS NULL;"

    ExecuteSqlStatement "$mySQLStatement" "$DATABASE_COMMAND"
}



#-----------------------------------------
#
# Procedure GetBranchType
#
# Arguments: $1 = branchURL
#-----------------------------------------
GetBranchType()
{
    local myURL=$1
    mySQLStatement="SELECT type_ FROM svnBranches_ WHERE url_ = \"$myURL\" AND deleted_ IS NULL;"

    ExecuteSqlStatement "$mySQLStatement" "$DATABASE_COMMAND"
}




#-----------------------------------------
#
# Procedure GetBranchCreatedRevision
#
# Arguments: $1 = branchURL
#
#-----------------------------------------
GetBranchCreatedRevision()
{
    local myURL=$1
    mySQLStatement="SELECT created_ FROM svnBranches_ WHERE url_ = \"$myURL\" AND deleted_ IS NULL;"

    ExecuteSqlStatement "$mySQLStatement" "$DATABASE_COMMAND"
}


#-----------------------------------------
#
# Procedure GetBranchName
#
# Returns the SVN branch name of the checkout from the directory it is run in
#-----------------------------------------
GetBranchName()
{
    local myURL=`GetBranchURL`
    echo `basename $myURL`
}



#-----------------------------------------
#
# Procedure GetBranchURL
#
# Returns the SVN URL of the checkout from the directory it is run in
#-----------------------------------------
GetBranchURL()
{
    echo `svn info | grep '^URL' | replacestr 'URL: ' '' ` | replacestr "$RESPONSIBLE_FOR_WEEKLY_MERGE""@" ""
}



#-----------------------------------------
#
#
# Procedure CheckForConflicts
#
#
#-----------------------------------------
CheckForConflicts()
{
    CONFLICTS=`svn status | grep '^C'`

    # If no conflicts detected, return 0
    if [ ! -n "$CONFLICTS" ]; then
        echo "No conflicts detected in directory `pwd`"
        return 0
    fi

    # ... otherwise return 1
    return 1
}



#-----------------------------------------
#
# Procedure Capitalize
#
# Arguments: $1 = stringToCapitalize
#
#-----------------------------------------
Capitalize()
{
    echo $1 | tr 'a-z' 'A-Z'
}




#-----------------------------------------
#
# Procedure StripUserNameFromSvnURL
#
# Arguments: $1 = svnURL
#
#-----------------------------------------
StripUserNameFromSvnURL()
{
    echo $1 | sed 's/svn+ssh:\/\/.*@/svn+ssh:\/\//'
}




#-----------------------------------------
#
# Procedure SendEMail
#
# Arguments: $1 = subject
#            $2 = body
#            $3 = To
#            $4 = CC
#            $5 = From
#
# Example: 
# SendEMail 'test' 'test body
# test body 2nd line' 'crpi@imc.nl pirnog@gmail.com' 
#-----------------------------------------
SendEMail()
{

    local mySubject=$1
    local myBody=$2
    local myTo=$3
    local myCC=$4
    local myFrom=$5

    local mySendmailOption=''
    if [ ! -z "$myFrom" ]; then
        mySendmailOption="-r $myFrom"
    fi

    echo "myTo = $myTo"
    echo "myCC = $myCC"
    echo "myFrom = $myFrom"

    echo -e "$myBody" | mail -s "$mySubject" -c "$myCC" "$mySendmailOption" "$myTo"
}

