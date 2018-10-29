#!/bin/bash

#***************************[help]********************************************
# 2018 10 29

function file_help() {

    echo ""
    echo "### $FUNCNAME ###"
    echo ""
    echo "filenames"
    echo -n "  "; file_name_clean -h
    echo -n "  "; file_name_clean_recursive -h
    echo -n "  "; file_name_expand -h
    echo ""
    echo "backup"
    echo -n "  "; file_backup_simple -h
    echo ""
}
