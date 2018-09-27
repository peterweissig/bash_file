#!/bin/bash

#***************************[help]********************************************
# 2018 09 27

function file_help() {

    echo ""
    echo "### $FUNCNAME ###"
    echo ""
    echo "filenames"
    echo -n "  "; file_name_clean -h
    echo -n "  "; file_name_expand -h
    echo ""
}
