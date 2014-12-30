#!/bin/bash

if [ $# -ne 1 ]
then
    echo "$0 serversToDeployTo [dev/cluster/both] buildServer"
    exit 1
fi

servers=$1
buildServer=$2

if [ "$buildServer" != "london" -a "$buildServer" != "chicago" ]
then
	echo "Buildserver has to be either london or chicago (now: $buildServer)!"
	exit 1
fi

if [ "$servers" == "dev" ]
then
	runBuild -p code --nocheck --upload dev -bs $buildServer --skip --post 1 &>/dev/null
elif [ "$servers" == "cluster" ]
then
	runBuild -p code --nocheck --upload cluster -bs $buildServer --skip --post 1 &>/dev/null
elif [ "$servers" == "both" ]
then
	runBuild -p code --nocheck --upload dev cluster -bs $buildServer --skip --post 1 &>/dev/null
else
	echo "Argument serversToDeployTo unknown: $servers (should be either dev, cluster or both)"
fi
