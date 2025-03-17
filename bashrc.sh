#!/bin/bash

#***************************[check if already sourced]************************
# 2019 12 01

if [ "$SOURCED_BASH_FILE" != "" ]; then

    return
    exit
fi

if [ "$SOURCED_BASH_LAST" == "" ]; then
    export SOURCED_BASH_LAST=1
else
    export SOURCED_BASH_LAST="$(expr "$SOURCED_BASH_LAST" + 1)"
fi

export SOURCED_BASH_FILE="$SOURCED_BASH_LAST"



#***************************[paths and files]*********************************
# 2020 12 27

temp_local_path="$(realpath "$(dirname "${BASH_SOURCE}")" )/"



#***************************[source]******************************************
# 2025 03 17

source "${temp_local_path}scripts/filename_functions.sh"
source "${temp_local_path}scripts/backup_functions.sh"
source "${temp_local_path}scripts/search_functions.sh"
source "${temp_local_path}scripts/modification_functions.sh"
source "${temp_local_path}scripts/help.sh"
