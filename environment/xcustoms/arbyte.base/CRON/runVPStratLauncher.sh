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
       lReceivingHost="localhost"
       lReceivingPort=17303
    fi

    local monitoringCommandStart="/usr/local/bin/python2.7 ./Yang/YangDbDealBookerStartup.py --h ${lReceivingHost} --p ${lReceivingPort} --l  ./Yang/kfc2_brand.so --hd OrderID,StrategyID,ExchangeID,OrderType,Side,Symbol,Size,Price,TIF,ExchangeTime,Status,ExeID,FillQty,FillPrice,PreviousOrderID,PreviousPrice --f ${lConfigFile} --w Y --hb 5 --ld ${lLogDir} --mail_to ${lRecipientsList} --e ${lRunType}"

    echo "Starting Yang using command: ${monitoringCommandStart}" >> ${outputFile}
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
# Source the base script
###############################
scriptDir=$(dirname ${0})
baseScript=${scriptDir}/base.sh
if [[ ! -f ${baseScript} ]]; then
    printf "Could not find base script %s" ${baseScript} >> ${outputFile}
    exit 1
fi

source ${baseScript}
source ${scriptDir}/email.sh

if [[ -z $(ls ${strategyConfigDir} | grep '.cfg$') ]]; then
    printf "No configs found in directory %s' ${strategyConfigDir}" >> ${outputFile}
    exit 1
fi

###############################
# Define some variables/constants
###############################
timeStamp=$(date +%Y%m%dT%H%M%S)
outputFile=${logDir}/output_${timeStamp}.log

arbyteDudes="${CRISTIAN} ${JENS} ${GIULIANO}"
recipientsList=${arbyteDudes}

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
    exitWithEMail "Binary not started" "${msg}" ${arbyteDudes} 1 ${outputFile}
fi

###############################
# Perform some checks
###############################
onloadCommand='/usr/bin/onload'
binaryName=$(ls | grep VPStratLauncher | grep -v RWDI_unstripped | tail -1)
if [[ -z ${binaryName} ]]; then
    exitWithEMail "Binary not started" "Could not find a binary to run. Exiting" ${arbyteDudes} 1 ${outputFile}
fi

strategyCommand="./${binaryName} --stratname ArByte --config ${configFile}"
if [[ -f ${onloadCommand} ]]; then
  strategyCommand="${onloadCommand} ${strategyCommand}"
fi

###############################
# Checks on the live log dir
###############################
if [[ -z $(mount | grep ${shmDir}) ]]; then
    exitWithEMail "Binary not started" "\n${shmDir} not mounted" ${recipientsList} 1 ${outputFile}
fi

mkdir -p ${logDir}
if [[ ! -d ${logDir} ]]; then
    exitWithEMail "Binary not started" "\nLog directory does not exist ${logDir}." ${recipientsList} 1 ${outputFile}
elif [[ ! -w ${logDir} ]]; then
    exitWithEMail "Binary not started" "\nLog directory is not writable by user." ${recipientsList} 1 ${outputFile}
fi


###############################
# Run the startup procedure
###############################
${scriptDir}/startup.sh >> ${outputFile}


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
export LD_LIBRARY_PATH=../lib:../3p_libs/ums/UMS_6.7/Linux-glibc-2.5-x86_64/lib:../3p_libs/lbm/LBM_4.2.6/lib/linux/x64:../3p_libs/tbb/tbb42_20130725oss/lib/intel64/gcc4.4:../3p_libs/poco/poco-1.4.6:/usr/local/lib64:/usr/local/lib
export LBM_LICENSE_INFO='Product=UME:Organization=SAC:Expiration-Date=never:License-Key=F7D4 6786 455F DAAA'
${strategyCommand} 2>&1 | tee -a ${outputFile}

###############################
# Stop Yang
###############################
if [[ ${noYang} != 1 ]]; then 
    stopYang
fi

#-------------- At this point the binary is stopped ----------------#

message="$(date): Binary stopped."


###############################
# Check for open positions
###############################
openPositions=$(grep -i 'Open position' ArByteLive* | grep 'shut')
if [[ -n ${openPositions} ]]; then
    sendMail "Open positions at shutdown" "${openPositions}" ${arbyteDudes}
fi

###############################
# Check for any core files
###############################
if [[ -n $(ls | grep core.) ]]; then
    # Send e-mail 
    chmod g+r core.*

    message=${message}" Found core dump file $(ls core.*)."
    sendMail "Core dump at shut down" "${message}" "${CRISTIAN} ${BRANDON}"
EOF

fi


# At the end, run the shutdown script
$(dirname ${0})/shutdown.sh --afterRun >> ${outputFile}
