#!/bin/bash

if [ $# -ne 2 ]
then
	echo -e "\t$0 symbol date"
	exit 1
fi

symbol=$1
date=$2

found=$(cat /mnt/config/RONIN/products.csv | awk -F ',' '{if($4=="'$symbol'"){print $0}}' | wc -l)
if [ $found -ne 1 ]
then
	echo -e "Symbol $symbol not found in /mnt/config/RONIN/products.csv"
	exit 1
fi

prodType=$(awk -F ',' '{if($4=="'$symbol'" || $3=="'$symbol'"){print $1}}' /mnt/config/RONIN/products.csv)
if [ "$prodType" == "FUTURE" ]
then
	found=$(find /home/$USER/scratch/cluster/MBBA/$symbol* -name "$date.mbba" | awk -F '/' '{if(length($7)==(length("'$symbol'")+2)){print $0}}' | wc -l)
else
	found=$(find /home/$USER/scratch/cluster/MBBA/$symbol* -name "$date.mbba" | awk -F '/' '{if(length($7)==(length("'$symbol'"))){print $0}}' | wc -l)
fi

if [ $found -gt 0 ]
then
	if [ "$prodType" == "FUTURE" ]
	then
		find /home/$USER/scratch/cluster/MBBA/$symbol* -name "$date.mbba" | awk -F '/' '{if(length($7)==(length("'$symbol'")+2)){print $0}}' | xargs ls -l
	else
		find /home/$USER/scratch/cluster/MBBA/$symbol* -name "$date.mbba" | awk -F '/' '{if(length($7)==(length("'$symbol'"))){print $0}}' | xargs ls -l
	fi
else
	echo -e "FILE NOT FOUND $symbol*/$date.mbba"
fi
