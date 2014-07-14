#!/bin/bash

function file_exists
{
   if [ ! -f $1 ]
   then
        echo "FILE NOT FOUND: $1"
        exit 1
   fi
}

if [ $# -lt 3 ]
then
        echo -e "\n$0 ronin/rocardian branchName Debug/Release [all optimizer arguments]\n"
        exit 1
else
	if [ "$1" != "ronin" -a "$1" != "rocardian" ]
	then
		echo -e "\n1st argument unknown: must be either ronin or rocardian\n"
		exit 1
	fi

	if [ "$3" != "Debug" -a "$3" != "Release" ]
        then
                echo -e "\n3rd argument unknown: must be either Debug or Release\n"
		exit 1
        fi
fi

client=$1
branch=$2
mode=$3

baseDir=/home/jepo/deploy/$branch/$mode
libDir=$baseDir/lib

if [ ! -d /home/jepo/deploy/$branch/ ]
then
	echo "DIRECTORY NOT FOUND: /home/jepo/deploy/$branch/ ; BRANCH NAME '$branch' INCORRECT?"
	exit 1
fi

if [ ! -d $baseDir -o ! -d $baseDir/bin/ ]
then
        echo "DIRECTORY NOT FOUND: $baseDir(/bin)"
        exit 1
fi

if [ ! -d $libDir ]
then
        echo "DIRECTORY NOT FOUND: $libDir"
        exit 1
fi

file=$baseDir/bin/$client".optimizer.exe"

file_exists $file

export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/lib:/usr/local/lib64:$libDir

shift 3
$file $@
