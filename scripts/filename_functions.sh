#!/bin/bash

#***************************[clear filename]**********************************
# 2020 01 09

function _file_name_clean_string() {

    # no help!

    # replace bad letters
    echo -n "$@" | \
      sed -z 's/[ /\t\n]\+/_/g' | \
      sed 's/ä/ae/g; s/ü/ue/g; s/ö/oe/g; s/Ä/Ae/g; s/Ü/Ue/g; s/Ö/Oe/g' | \
      sed 's/ß/ss/g' | \
      sed 's/[^-a-zA-Z0-9_.,;*+=#~()]/#/g'
}

# 2020 01 09
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
        echo "The file extension will be set to small letters."
        echo "  (e.g. from \"file.TXT\" to file.txt)"
        echo "Any character except for alphanumerics (A-Z & 0-9) and some"
        echo "  special characters (_.,;*+-=#~()) will be replaced by an #."

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
    if [ "$1" == "" ]; then
        readarray -t filelist <<< "$(ls --quote-name)"
    else
        readarray -t filelist <<< "$(ls --quote-name "$1")"
    fi

    # iterate over all files
    for i in ${!filelist[@]}; do
        # remove outer quotes
        temp="$(echo "${filelist[$i]:1:-1}")"

        # expand special characters and simplify \" to "
        filelist[$i]="$(printf "${temp}")"

        # replace bad letters
        corrected[$i]="$(_file_name_clean_string "${filelist[$i]}")";

        # correct extension
        ext="${corrected[$i]/*./.}"
        if [ "$ext" != "${corrected[$i]}" ]; then
            base="${corrected[$i]%.*}"

            ext="${ext,,}";
            corrected[$i]="${base}${ext}"
        fi

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
    echo -n "Do you wish to continue ? (Yes/no)"
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

# 2019 01 10
function file_name_clean_recursive() {

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
        echo "Any character except for alphanumerics (A-Z & 0-9) and some"
        echo "  special characters (_.,;*+-=#~()) will be replaced by an #."

        return
    fi

    # check parameter
    if [ $# -gt 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # clean local path
    echo "[$(pwd)/]"
    if [ $# -gt 0 ]; then
        file_name_clean "$1"
    else
        file_name_clean
    fi
        # check result
        if [ $? -ne 0 ]; then return -1; fi

    # find all subfolder
    readarray -t filelist <<< "$(ls -d */ 2>> /dev/null)"
        # check result
        if [ $? -ne 0 ]; then return; fi

    # iterate over all subdirs
    file_name_clean_recursive__filelist=("${filelist[@]}");
    for i in ${!filelist[@]}; do
        if [ "${filelist[$i]}" == "" ]; then continue; fi

        # call this functions recursive
        if [ $# -gt 0 ]; then
            (cd "${filelist[$i]}" && file_name_clean_recursive "$1")
        else
            (cd "${filelist[$i]}" && file_name_clean_recursive)
        fi
            # check result
            if [ $? -ne 0 ]; then return -1; fi

        filelist=("${file_name_clean_recursive__filelist[@]}")
    done
}

#***************************[expand filename]*********************************
# 2018 12 01

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
    if [ $# -lt 3 ]; then
        readarray -t filelist <<< "$(ls)"
    else
        readarray -t filelist <<< "$(ls "$3")"
    fi

    # iterate over all files
    for i in ${!filelist[@]}; do
        # split filename
        path="$(dirname "${filelist[$i]}")"
        if [ "$path" == "." ]; then
            path="";
        else
            path="${path}/";
        fi

        baseext="$(basename "${filelist[$i]}")"
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
    echo -n "Do you wish to continue ? (No/yes)"
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

#***************************[erode filename]**********************************
# 2019 01 09

function file_name_erode() {

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
        echo "  \"<path><filename without prefix or suffix><extension>\"."
        echo "  (e.g. from file_image_new.jpg to image.jpg)."

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
    if [ $# -lt 3 ]; then
        readarray -t filelist <<< "$(ls)"
    else
        readarray -t filelist <<< "$(ls "$3")"
    fi

    # iterate over all files
    for i in ${!filelist[@]}; do
        # split filename
        path="$(dirname "${filelist[$i]}")"
        if [ "$path" == "." ]; then
            path="";
        else
            path="${path}/";
        fi

        baseext="$(basename "${filelist[$i]}")"
        base="${baseext%.*}"
        ext="${baseext/*./.}"
        if [ "$ext" == "$baseext" ]; then
            ext="";
        fi

        # create new name
        updated[$i]="$(echo -n "${filelist[$i]}" | \
          sed "s/^${1}\\(.*\\)${2}\$/\1/")";
          # sed "s/^<prefix>\(.*\)<suffix>$/\1/"

        # rename file
        if [ "${filelist[$i]}" != "${updated[$i]}" ]; then
            echo "  \"${filelist[$i]}\" ==> \"${updated[$i]}\""
            changed=1
        fi
    done

    if [ $changed -eq 0 ]; then
        # output if nothing was changed
        echo "No files found :-("
        return
    fi

    # ask user if continuing
    echo -n "Do you wish to continue ? (No/yes)"
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
