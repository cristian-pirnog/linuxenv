#/bin/bash

baseScript=${HOME}/CRON/base.sh
source ${baseScript}

echo rsync -azvh ${arbyteNAS}:${libraryDirOnNAS}/ ${libraryDir}

