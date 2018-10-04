#!/bin/bash

#***************************[filename]****************************************
# 2018 10 04

function file_name_clean() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME [<filter>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 0-1 parameters"
        echo "    [#1:]search-expression (e.g. \"*.jpg\")"
        echo "         Leave option empty to rename all files and dirs."
        echo "         For wildcard-expressions please use double-quotes."
        echo "The files will be renamed to remove ä, ü, ö, ß and spaces."
        echo "  (e.g. from \"file ä ß Ö.ext\" to file_ae_ss_Oe.ext)"

        return
    fi

    # check parameter
    if [ $# -gt 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # init variables
    changed=0
    corrected=()

    # read all filenames
    readarray -t filelist <<< "$(ls $1)"

    # iterate over all files
    for i in ${!filelist[@]}; do
        # replace bad letters
        corrected[i]=$(echo "${filelist[$i]}" | \
          sed 's/[ /\:]\+/_/g' | \
          sed 's/ä/ae/g; s/ü/ue/g; s/ö/oe/g; s/Ä/Ae/g; s/Ü/Ue/g; s/Ö/Oe/g' | \
          sed 's/ß/ss/g');

        # check if filename would change
        if [ "${filelist[$i]}" != "${corrected[$i]}" ]; then
            echo "  \"${filelist[$i]}\" ==> \"${corrected[$i]}\""
            changed=1
        fi
    done

    if [ $changed -eq 0 ]; then
        # output if nothing was changed
        echo "All files and dirs comply :-)"
        return
    fi

    # ask user if continuing
    echo -n "Do you wish to continue (Y/n)?"
    read answer
    if [ "$answer" != "" ] && \
      [ "$answer" != "y" ] && [ "$answer" != "Y" ] && \
      [ "$answer" != "yes" ]; then

        echo "$FUNCNAME: Aborted."
        return
    fi

    # iterate over all files
    for i in ${!filelist[@]}; do
        # check for errors
        if [ $? -ne 0 ]; then
            echo "$FUNCNAME: Stopping because of an error."
            return -1;
        fi

        # check if filename would change
        if [ "${filelist[$i]}" != "${corrected[$i]}" ]; then
            echo "renaming \"${corrected[$i]}\""
            mv "${filelist[$i]}" "${corrected[$i]}"
        fi
    done
}

function file_name_expand() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME <prefix> [<suffix>] [<filter>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 1-3 parameters"
        echo "     #1: additional prefix (e.g. file_)"
        echo "    [#2:]additional suffix (e.g. _new)"
        echo "    [#3:]search-expression (e.g. \"*.jpg\")"
        echo "         Leave option empty to rename all files and dirs."
        echo "         For wildcard-expressions please use double-quotes."
        echo "The output files and dirs will be named"
        echo "  \"<path><prefix><filename><suffix><extension>\"."
        echo "  (e.g. from image.jpg to file_image_new.jpg)."

        return
    fi

    # check parameter
    if [ $# -lt 1 ] || [ $# -gt 3 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # init variables
    changed=0
    updated=()

    # read all filenames
    readarray -t filelist <<< "$(ls $3)"

    # iterate over all files
    for i in ${!filelist[@]}; do
        # split filename
        path="$(dirname ${filelist[$i]})"
        if [ "$path" == "." ]; then
            path="";
        else
            path="${path}/";
        fi

        baseext="$(basename ${filelist[$i]})"
        base="${baseext%.*}"
        ext="${baseext/*./.}"
        if [ "$ext" == "$baseext" ]; then
            ext="";
        fi

        # create new name
        updated[$i]="${path}${1}${base}${2}${ext}"

        # rename file
        echo "  \"${filelist[$i]}\" ==> \"${updated[$i]}\""
        changed=1
    done

    if [ $changed -eq 0 ]; then
        # output if nothing was changed
        echo "No files found :-("
        return
    fi

    # ask user if continuing
    echo -n "Do you wish to continue (N/y)?"
    read answer
    if [ "$answer" != "y" ] && [ "$answer" != "Y" ] && \
      [ "$answer" != "yes" ]; then

        echo "$FUNCNAME: Aborted."
        return
    fi

    # iterate over all files
    for i in ${!filelist[@]}; do
        # check for errors
        if [ $? -ne 0 ]; then
            echo "$FUNCNAME: Stopping because of an error."
            return -1;
        fi

        # check if filename would change
        if [ "${filelist[$i]}" != "${updated[$i]}" ]; then
            echo "renaming \"${updated[$i]}\""
            mv "${filelist[$i]}" "${updated[$i]}"
        fi
    done
}
