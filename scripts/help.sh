#!/bin/bash

#***************************[all]*********************************************
# 2018 10 31

function file_help_all() {


    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 0 parameters"
        echo "Prints all available functions within repository \"file\"."

        return
    fi

    # check parameter
    if [ $# -gt 0 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # print overview of all repositories
    echo ""
    echo "### $FUNCNAME ###"
    echo ""
    echo "help"
    echo -n "  "; echo "file_help"
    echo -n "  "; file_help_all -h
    echo ""
    echo "filenames"
    echo -n "  "; file_name_clean -h
    echo -n "  "; file_name_clean_recursive -h
    echo -n "  "; file_name_expand -h
    echo ""
    echo "backup"
    echo -n "  "; file_backup_simple -h
    echo -n "  "; file_backup_inplace -h
    echo -n "  "; _file_backup_base -h
    echo ""
}

#***************************[help]********************************************
# 2018 10 31

function file_help() {

    echo ""
    echo "### $FUNCNAME ###"
    echo ""
    echo "help functions"
    echo -n "  "; echo "file_help"
    echo -n "  "; file_help_all -h
    echo ""
    echo "filenames"
    echo -n "  "; file_name_clean -h
    echo -n "  "; file_name_expand -h
    echo ""
    echo "backup"
    echo -n "  "; file_backup_simple -h
    echo -n "  "; file_backup_inplace -h
    echo ""
}
