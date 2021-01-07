#!/bin/bash

#***************************[all]*********************************************
# 2021 01 07

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
    echo -n "  "; echo "file_help  #no help"
    echo -n "  "; $FUNCNAME -h
    echo ""
    echo "filenames"
    echo -n "  "; file_name_clean -h
    echo -n "  "; file_name_clean_recursive -h
    echo -n "  "; file_name_expand -h
    echo -n "  "; file_name_erode -h
    echo "  _file_name_clean_string  #no help"
    echo ""
    echo "backup"
    echo -n "  "; file_backup_simple -h
    echo -n "  "; file_backup_inplace -h
    echo -n "  "; _file_backup_base -h
    echo -n "  "; _file_backup_simplify_name -h
    if [ "$(type -t config_file_backup)" != "" ]; then
        echo ""
        echo -n "  see also: "; config_file_backup -h
    fi
    echo ""
    echo "search"
    echo -n "  "; file_search -h
    echo ""
}

#***************************[help]********************************************
# 2021 01 07

function file_help() {

    echo ""
    echo "### $FUNCNAME ###"
    echo ""
    echo "help functions"
    echo -n "  "; echo "$FUNCNAME  #no help"
    echo -n "  "; file_help_all -h
    echo ""
    echo "filenames"
    echo -n "  "; file_name_clean -h
    echo -n "  "; file_name_expand -h
    echo -n "  "; file_name_erode -h
    echo ""
    echo "backup"
    echo -n "  "; file_backup_simple -h
    echo -n "  "; file_backup_inplace -h
    if [ "$(type -t config_file_backup)" != "" ]; then
        echo ""
        echo -n "  see also: "; config_file_backup -h
    fi
    echo ""
    echo "search"
    echo -n "  "; file_search -h
    echo ""
}
