#!/bin/bash

baseDir=/mnt/data/deploy/Release/lib

export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/lib:/usr/local/lib64:$baseDir
${baseDir}/ronin.optimizer $@
