#!/bin/bash


#-------------------------
# Function GetDateName
#-------------------------
GetDateName()
{
    local lFileName=${1}
    local lTag="${2}"
    exiftool -d "%Y%m%d_%H-%M-%S" ${lFileName} | grep "$lTag" | head -1 | awk -F ':' '{print $NF}' | replace ' ' '' | replace '\-' ':' | replace '_' '-'
}


#-------------------------
# Main script
#-------------------------

for f in $*
do
    if [[ -z $(echo $f | grep -E -v '(IMG|MOV)_[[:digit:]]{8}-([[:digit:]]{2}:){2}[[:digit:]]{2}') ]]; then
	echo "File name already cool: $f"
	continue
    fi

    lExtension=$(echo ${f} | awk -F '.' '{print $NF}')
    if [[ -z $(echo -e "jpg\nmpg\nmov\nm2ts\nmts\nmp4" | grep -i ${lExtension}) ]]; then
	echo "Skipping (unknown file type) ${f}"
	continue
    fi

    if [[ -n $(echo -e "m2ts\nmts" | grep -i ${lExtension}) ]]; then
	myTag="^Date/Time Original"
    else
	myTag='^Create Date'
    fi

    dateName=$(GetDateName $f "$myTag")

    if [[ $(echo ${dateName} | awk -F '_' '{print $1}' | sed 's/\///') < 20000101 ]]; then
	echo "Date ${myDate} too old for file ${f}."
	dateName=""
    fi

    if [[ -z ${dateName} ]]; then
	dateName=$(GetDateName $f '^File Modification Date/Time')
    fi

    if [[ -z ${dateName} ]]; then
	echo  "Could not get Date/Time for file $f. Skipping"
	continue
    fi

    prefix='IMG'
    if [[ -n $(echo -e "mpg\nmov\nmp4" | grep -i ${lExtension}) ]]; then
	prefix='MOV'
    fi

    suffix=''
    index=0
    noTargetFile=0
    for i in {1..10}; do
	fileName=${prefix}_${dateName}${suffix}.${lExtension}
	if [[ -f ${fileName} ]]; then
	    index=$((index + 1))
	    suffix=_${index}
	    continue
	fi
	noTargetFile=1
    done

    if [[ $noTargetFile -eq 0 ]]; then
	echo "Target file ${fileName} already exists. Will not rename file $f"
	continue
    fi

    chmod u+w $f
    mv -v $f ${fileName}
    replace -s $f ${fileName} -- checksums
    chmod u-wx ${fileName}
done




