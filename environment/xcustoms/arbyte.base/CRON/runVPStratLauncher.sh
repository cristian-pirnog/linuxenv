#!/bin/bash

#----------------------------------------------
printUsage()
{
    cat << %%USAGE%%

    Usage: $(basename ${0}) [-h]
           $(basename ${0}) [--noYang]

    Description:
        Run the VPStratLauncher binary.

    Options:
       -h
       --help
             Print this help message and exit.

       --noYang
             Do not start the Yang monitoring tool.

%%USAGE%%
}


#----------------------------------------------
startYang()
{
    local lConfigFile=${1}
    local lLogDir=${2}
    local lRecipientsList=${3}

    local lRunType=PROD
    local lReceivingHost="10.194.77.90"
    local lReceivingPort=7303
    if [[ ${USER} == arbytetest ]]; then
       lRunType=DEV
       lReceivingHost="10.194.77.51"
       lReceivingPort=17303
    fi

    local monitoringCommandStart="/usr/local/bin/python2.7 ./Yang/YangDbDealBookerStartup.py --h ${lReceivingHost} --p ${lReceivingPort} --l  ./Yang/kfc2_brand.so --hd OrderID,StrategyID,ExchangeID,OrderType,Side,Symbol,Size,Price,TIF,ExchangeTime,Status,ExeID,FillQty,FillPrice,PreviousOrderID,PreviousPrice --f ${lConfigFile} --w Y --hb 5 --ld ${lLogDir} --mail_to ${lRecipientsList} --e ${lRunType}"

    echo "Starting Yang using command: ${monitoringCommandStart}" >> ${outputFile}
    echo "" >> ${outputFile}
    ${monitoringCommandStart} >> ${outputFile} 2>>${outputFile}
}

#----------------------------------------------
stopYang()
{
    echo "Stopping Yang" >> ${outputFile}
    /usr/local/bin/python2.7 ./Yang/StopYangDbDealBooker.py --i all
}



#----------------------------------------------
# Main script
#----------------------------------------------
ARGS=$(getopt -o h -l "help,noYang" -n "$(basename ${0})" -- "$@")

# If wrong arguments, print usage and exit
if [[ $? -ne 0 ]]; then
    printUsage
    exit 1;
fi

eval set -- "$ARGS"

## Parse options
noYang=0
while true; do
    case ${1} in
    -h|--help)
        printUsage
        exit 0
        ;;
    --noYang)
	noYang=1
	shift
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

###############################
# Define some variables/constants
###############################
date=$(date +%Y%m%d)
timeStamp=$(date +%Y%m%dT%H%M%S)
outputFile=output_${timeStamp}.log
logDir='../log'

CRISTIAN='pirnog@gmail.com'
GIULIANO='giuliano.tirenni@gmail.com'
JENS='jens.poepjes@gmail.com'
BRANDON='bleung@vitessetech.com'
recipientsList="${CRISTIAN} ${JENS} ${GIULIANO}"


###############################
# Test the config file
###############################
configFile="arbyte.xml"
if [[ ! -f ${configFile} ]]; then
    printf "\n No ${configFile} found. Will not start the binary.\n\n" >> ${outputFile}
    exit 0
fi

xmllint --noout ${configFile}
if [[ $? -ne 0 ]]; then
    printf "\nError in the config file %s. Will not start the binary.\n\n" ${configFile} >> ${outputFile}
    exit 1
fi

###############################
# Perform some checks
###############################
binaryName=$(ls | grep VPStratLauncher | grep -v RWDI_unstripped | tail -1)
strategyCommand="./${binaryName} --stratname ArByte --config ${configFile}"
if [[ -z ${binaryName} ]]; then
    echo "Could not find a binary to run. Exiting" >> ${outputFile}
    exit 1
fi

# Check that VPStratLauncher is not alredy running
if [[ -n $(fp "${strategyCommand} ") ]]; then
    echo "StrategyCommand ${strategyCommand} already running. Exiting" >> ${outputFile}
    exit 1
fi

###############################
# Start Yang
###############################
if [[ ${noYang} != 1 ]]; then 
    startYang ${configFile} ${logDir} "${recipientsList}"
else
    echo "Not starting Yang" >> ${outputFile}
fi

###############################
# Start the binary
###############################
echo "Starting the binary using command: ${strategyCommand}" >> ${outputFile}
export LD_LIBRARY_PATH=../lib:../3p_libs/ums/UMS_6.7/Linux-glibc-2.5-x86_64/lib:../3p_libs/lbm/LBM_4.2.6/lib/linux/x64:../3p_libs/tbb/tbb42_20130725oss/lib/intel64/gcc4.4:../3p_libs/poco/poco-1.4.6:../3p_libs/fix8/fix8-1.3.1/lib:/usr/local/lib64:/usr/local/lib
export LBM_LICENSE_INFO='Product=UME:Organization=SAC:Expiration-Date=never:License-Key=F7D4 6786 455F DAAA'
${strategyCommand} | tee -a ${outputFile}

###############################
# Stop Yang
###############################
if [[ ${noYang} != 1 ]]; then 
    stopYang
fi

#-------------- At this point the binary is stopped ----------------#

message="$(date): Binary stopped."


###############################
# Check for any core files
###############################
if [[ -n `ls | grep core.` ]]; then
    # Send e-mail 
    recipientsList="${recipientsList} ${BRANDON}"
    message=${message}" Found core dump file $(ls core.*)."
    chmod g+r core.*
fi

mail -s "${USER}@${HOST}: binary stopped" ${recipientsList} << EOF
${message}
EOF

# At the end, run the shutdown script
$(dirname ${0})/shutdown.sh --afterRun
