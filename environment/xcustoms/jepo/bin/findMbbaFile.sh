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

found=$(find /home/data/RONIN/MBBA/$symbol* -name "$date.mbba" | awk -F '/' '{if(length($6)==(length("'$symbol'")+2)){print $0}}' | wc -l)
if [ $found -gt 0 ]
then
	find /home/data/RONIN/MBBA/$symbol* -name "$date.mbba" | awk -F '/' '{if(length($6)==(length("'$symbol'")+2)){print $0}}' | xargs ls -l
else
	echo -e "FILE NOT FOUND $symbol*/$date.mbba"
fi
