#!/bin/bash

#***************************[check if already sourced]************************
# 2018 11 30

if [ "$SOURCED_BASH_FILE" != "" ]; then

    return
    exit
fi

export SOURCED_BASH_FILE=1

#***************************[paths and files]*********************************
# 2018 11 17

temp_local_path="$(cd "$(dirname "${BASH_SOURCE}")" && pwd )/"


#***************************[source]******************************************
# 2018 10 29

. ${temp_local_path}scripts/filename_functions.sh
. ${temp_local_path}scripts/backup_functions.sh
. ${temp_local_path}scripts/help.sh
