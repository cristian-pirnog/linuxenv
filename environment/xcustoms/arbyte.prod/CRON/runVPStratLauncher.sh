#/bin/bash

#----------------------------------------------
printUsage()
{
    cat << %%USAGE%%
         Usage: $(basename ${0}) [-h]

    Description:
        Run the VPStratLauncher binary.

    Options:
       -h
       --help
             Print this help message and exit.

%%USAGE%%
}

#----------------------------------------------
# Main script
#----------------------------------------------
ARGS=$(getopt -o h -l "help" -n "$(basename ${0})" -- "$@")

# If wrong arguments, print usage and exit
if [[ $? -ne 0 ]]; then
    printUsage
    exit 1;
fi

eval set -- "$ARGS"

## Parse options
while true; do
    case ${1} in
    -h|--help)
        printUsage
        exit 0
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
runType=PROD
if [[ ${USER} == arbytetest ]]; then
   runType=DEV
fi

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
xmllint --noout ${configFile}
if [[ $? -ne 0 ]]; then
    printf "\nError in the config file %s. Will not start the binary.\n\n" ${configFile}
fi

###############################
# Prepare the commands to execute
###############################
productionHost="10.194.77.90"
productionPort=7303
monitoringCommandStart="/usr/local/bin/python2.7 ./Yang/YangDbDealBookerStartup.py --h ${productionHost} --p ${productionPort} --l  ./Yang/kfc2_brand.so --hd OrderID,StrategyID,ExchangeID,OrderType,Side,Symbol,Size,Price,TIF,ExchangeTime,Status,ExeID,FillQty,FillPrice,PreviousOrderID,PreviousPrice --f ${configFile} --w Y --hb 5 --ld ${logDir} --mail_to ${recipientsList} --e ${runType}"
monitoringCommandStop='/usr/local/bin/python2.7 ./Yang/StopYangDbDealBooker.py --i all'
binaryName=$(ls | grep VPStratLauncher | grep -v RWDI_unstripped | tail -1)
strategyCommand="./${binaryName} --stratname ArByte --config ${configFile}"

###############################
# Perform some checks
###############################
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
# Prepare the environment
###############################
# Touch the cmeRecoverFile (do not clear, in case of restart)
cmeRecoverFile='../dat/cmearbp1_recover.csv'
touch ${cmeRecoverFile}


###############################
# Start Yang and VPStratLauncher
###############################
export LD_LIBRARY_PATH=../lib:../3p_libs/ums/UMS_6.7/Linux-glibc-2.5-x86_64/lib:../3p_libs/lbm/LBM_4.2.6/lib/linux/x64:../3p_libs/tbb/tbb42_20130725oss/lib/intel64/gcc4.4:../3p_libs/poco/poco-1.4.6:../3p_libs/fix8/fix8-1.3.1/lib:/usr/local/lib64:/usr/local/lib
export LBM_LICENSE_INFO='Product=UME:Organization=SAC:Expiration-Date=never:License-Key=F7D4 6786 455F DAAA'

echo "Starting monitoring using command: ${monitoringCommandStart}" > ${outputFile}
${monitoringCommandStart}
echo "Starting the binary using command: ${strategyCommand}" >> ${outputFile}
${strategyCommand} | tee -a ${outputFile}
${monitoringCommandStop}

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
