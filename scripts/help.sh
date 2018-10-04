#!/bin/bash

#***************************[help]********************************************
# 2018 10 04

function file_help() {

    echo ""
    echo "### $FUNCNAME ###"
    echo ""
    echo "filenames"
    echo -n "  "; file_name_clean -h
    echo -n "  "; file_name_clean_recursive -h
    echo -n "  "; file_name_expand -h
    echo ""
}
