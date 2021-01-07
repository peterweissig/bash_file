#!/bin/bash

#***************************[search]******************************************
# 2021 01 07

function file_search() {

    # print help
    if [ "$1" == "-h" ]; then
        echo -n "$FUNCNAME [--no-subdirs] [--only-dirs] "
        echo "<filename> [<search-path>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME has 2 options and needs 1-2 parameters"
        echo "    [--no-subdirs] avoids nested and almost nested results"
        echo "                   (a/x --> a/x/x & a/c/x are ignored)"
        echo "    [--only-dirs]  only directorys are listed"
        echo "     #1: file/folder to search for (e.g. \".git\")"
        echo "    [#2:]search place (default current folder)"
        echo "Searches for the all files or folders with the given name."

        return
    fi

    # init variables
    option_no_subdir=0
    option_only_dirs=0
    param_file=""
    param_path=""

    # check and get parameter
    params_ok=0
    if [ $# -ge 1 ] && [ $# -le 4 ]; then
        params_ok=1
        while true; do
            if [ "$1" == "--no-subdirs" ]; then
                option_no_subdir=1
                shift
                continue
            elif [ "$1" == "--only-dirs" ]; then
                option_only_dirs=1
                shift
            elif [[ "$1" =~ ^-- ]]; then
                echo "$FUNCNAME: Unknown option \"$1\"."
                return -1
            else
                break
            fi
        done
        param_file="$1"
        param_path="$2"
        if [ $# -lt 1 ] || [ $# -gt 2 ]; then
            params_ok=0
        fi
    fi
    if [ $params_ok -ne 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    if [ "$param_path" != "" ]; then
        if [ ! -d "$param_path" ]; then
            echo "Search path \"$param_path\" does not exist."
            return -2
        fi
    fi

    # find all occurances
    only_dirs=""
    if [ $option_only_dirs -eq 1 ]; then
        only_dirs="-type d"
    fi
    if [ "$param_path" != "" ]; then
        readarray -t files <<< "$(find "$param_path" \
          -iname "$param_file" $only_dirs)"
    else
        readarray -t files <<< "$(find \
          -iname "$param_file" $only_dirs)"
    fi
    if [ $? -ne 0 ]; then return -3; fi

    # remove (almost) nested results
    if [ $option_no_subdir -eq 1 ]; then
        # get parent path
        for i in ${!files[@]}; do
            files_parent[$i]="$(dirname "${files[$i]}")/"
        done
        # iterate over all parents
        for i in ${!files_parent[@]}; do

            # check if others are a parent of current directory
            for j in ${!files_parent[@]}; do
                if [ $i -eq $j ]; then continue; fi
                length_other="${#files_parent[$j]}"
                if [ $length_other -gt ${#files_parent[$i]} ]; then
                    continue;
                fi
                temp="${files_parent[$i]:0:$length_other}"
                if [ "${files_parent[$j]}" != "${temp}" ]; then
                    continue;
                fi
                files[$i]=""
                break;
            done
        done
    fi

    # iterate over all files
    for i in ${!files[@]}; do
        if [ "${files[$i]}" != "" ]; then
            echo "${files[$i]}"
        fi
    done
}
