#!/bin/bash

# This file contains variables and functions that have something to do with running
# database queries.
#
#


# The command for the Matlab production database
DATABASE_COMMAND='mysql -h qwery -u archiver -psecret sag_matlab_felix_tb11'


#-----------------------------------------
#
# Procedure ExecuteSqlStatement
#
# Arguments: $1 = statement
#            $2 = databaseCommand
#-----------------------------------------
ExecuteSqlStatement()
{
    local myStatement=$1
    local myDatabaseCommand=$2

    echo $myStatement | $myDatabaseCommand | tail -n 1
}



#-----------------------------------------
#
# Procedure InsertSvnBranch
#
# Arguments: $1 = originName
#            $2 = targetName
#            $3 = revision
#            $4 = responsible
#            $5 = svnUrl
#            $6 = type
#            $7 = status
#
#-----------------------------------------
InsertSvnBranch()
{
    # Parse input arguments
    local myOriginName=$1
    local myTargetName=$2
    local myRevision=$3
    local myResponsible=$4
    local myUrl=$5
    local myType=`Capitalize $6`
    local myStatus=`Capitalize $7`

    local myOriginId=`GetActiveBranchId "$myOriginName"`
    local myTargetId=`GetActiveBranchId "$myTargetName"`


    local myStatement="INSERT INTO svnBranches_ (name_, responsible_, type_, url_, origin_, originName_, status_, keepSyncrhonized_, created_, deleted_) VALUES ('$myTargetName', '$myResponsible', '$myType', '$myUrl', $myOriginId, '$myOriginName', '$myStatus', TRUE, $myRevision, NULL);"
    echo "$myStatement" | $DATABASE_COMMAND
}



#-----------------------------------------
#
# Procedure InsertSvnMerge
#
# Arguments: $1 = originName
#            $2 = targetName
#            $3 = revisionRange (r1-r2)
#            $4 = responsible
#
#-----------------------------------------
InsertSvnMerge()
{
    # Parse input arguments
    local myOriginName=$1
    local myTargetName=$2
    local myRevisionRange=`echo $3 | replacestr "-" ", "`
    local myResponsible=$4

    local myOriginId=`GetActiveBranchId "$myOriginName"`
    local myTargetId=`GetActiveBranchId "$myTargetName"`


    local myStatement="INSERT INTO svnMerges_ (origin_, target_, fromRevision_, toRevision_, author_, created_) VALUES ($myOriginId, $myTargetId, $myRevisionRange, '$myResponsible', '$UNIX_TIME_STAMP');"
    echo "$myStatement" | $DATABASE_COMMAND
}

