#!/bin/bash

#***************************[_file_backup_simplify_name]**********************
# 2022 09 05

function _file_backup_simplify_name() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME <basename> [<name_style>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 1-2 parameters"
        echo "     #1: basename of file to be backed up"
        echo "         (e.g. \"table.odt\" or \"fstab\")"
        echo "    [#2:]naming convention - prefix, suffix or both"
        echo "         \"prefix\" --> only remove prepended date/number"
        echo "         \"suffix\" --> only remove extended  date/number"
        echo "         \"both\"   --> remove prefix and suffix (default)"
        echo "This function will simplify the given filename by stripping"
        echo "possible dates (and consecutive numbers)."
        echo "In case of hidden files, the preceeding dot is always removed."

        return
    fi

    # check parameter
    if [ $# -lt 1 ] || [ $# -gt 2 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # check name style
    if [ $# -gt 1 ]; then
        name_style="$2"
    else
        name_style="both"
    fi

    remove_prefix=0
    remove_suffix=0
    if [ "$name_style" == "prefix" ]; then
        remove_prefix=1
    fi
    if [ "$name_style" == "suffix" ]; then
        remove_suffix=1
    fi
    if [ "$name_style" == "both" ]; then
        remove_prefix=1
        remove_suffix=1
    fi

    if [ $remove_prefix -eq 0 ] && [ $remove_suffix -eq 0 ]; then
        echo "$FUNCNAME: Naming style must be prefix, suffix or both."
        echo "  (not \"$name_style\")"
        return -1
    fi

    # init variables
    filebase="$1"

    # check for simplification of name
    # check prefix of filename
    if [ $remove_prefix -gt 0 ]; then
        remove_count=0
        if [ ${#filebase} -gt 5 ] && \
        [[ "${filebase:0:5}" == [0-9][0-9][0-9][0-9]_ ]]; then

            # check "year_month_" (before filename)
            if [ ${#filebase} -gt 8 ] && \
            [[ "${filebase:5:3}" == [0-9][0-9]_ ]]; then

                # check "year_month_day_" (before filename)
                if [ ${#filebase} -gt 11 ] && \
                [[ "${filebase:8:3}" == [0-9][0-9]_ ]]; then

                    # check "year_month_day_nrs_" (before filename)
                    if [ ${#filebase} -gt 15 ] && \
                    [[ "${filebase:11:4}" == [0-9][0-9][0-9]_ ]]; then
                        # removing all
                        remove_count=15
                    else
                        # removing year, month and day
                        remove_count=11
                    fi
                else
                    # removing year and month
                    remove_count=8
                fi
            else
                # removing year
                remove_count=5
            fi
        fi
        while [ "${filebase:${remove_count}:1}" == "_" ]; do
            remove_count=$(( $remove_count + 1 ))
        done
        if [ "${remove_count}" -gt 0 ]; then
            #echo "ignoring prefix \"${filebase:0:${remove_count}}\""
            filebase="${filebase:${remove_count}}"
        fi
    fi

    # check suffix of filename
    if [ $remove_suffix -gt 0 ]; then
        remove_count=0
        temp="_[0-9][0-9][0-9][0-9]_[0-9][0-9]_[0-9][0-9]_[0-9][0-9][0-9]"
        if [ ${#filebase} -gt 15 ] && [[ "${filebase: -15:15}" == $temp ]]; then
            # removing all
            remove_count=15
        else
            temp="_[0-9][0-9][0-9][0-9]_[0-9][0-9]_[0-9][0-9]"
            if [ ${#filebase} -gt 11 ] && [[ "${filebase: -11:11}" == $temp ]]; then
                # removing year, month and day
                remove_count=11
            fi
        fi
        while [ "${filebase: -${remove_count}:1}" == "_" ]; do
            remove_count=$(( $remove_count + 1 ))
        done
        remove_count=$(( $remove_count - 1 ))
        if [ "${remove_count}" -gt 0 ]; then
            #echo "ignoring suffix \"${filebase: -${remove_count}}\""
            filebase="${filebase:0:${#filebase}-${remove_count}}"
        fi
    fi

    # check if final filename starts with an dot (hidden file)
    if [ "${filebase:0:1}" == "." ]; then
        filebase="${filebase:1}"
    fi

    echo "$filebase"
}


#***************************[_file_backup_base]*******************************
# 2022 09 05

function _file_backup_base() {

    # print help
    if [ "$1" == "-h" ]; then
        echo -n "$FUNCNAME <filename> <backup_path> <name_style> "
        echo "[<auto-answer>] [<copy-with-sudo>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 3-5 parameters"
        echo "     #1: name/path of file to be backed up"
        echo "         (e.g. \"~/table.odt\" or \"/etc/fstab\")"
        echo "     #2: path of backup-folder (e.g. \"~/backup/\")"
        echo "         this string needs to end in \"/\""
        echo "     #3: naming convention - either prefix or suffix filename"
        echo "         with current date (and consecutive number)"
        echo "         \"prefix\" --> ~/backup/2018_10_30[_004]__table.odt"
        echo "         \"suffix\" --> ~/backup/fstab__2017_11_01[_002]"
        echo "    [#4:]using auto-answer for secondary backup"
        echo "         (must be \"-y\" or \"--yes\" to be in effect)"
        echo "    [#5:]using sudo to read and copy file"
        echo "         (must be \"sudo\" to be in effect)"
        echo "This function will copy the given file to the backup-folder"
        echo "and prepend or extend it with the current date."
        echo "In case of hidden files, the preceeding dot is always removed."

        return
    fi

    # check parameter
    if [ $# -lt 3 ] || [ $# -gt 5 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    name_style="$3"
    if [ "$name_style" != "prefix" ] && [ "$name_style" != "suffix" ]; then
        echo "$FUNCNAME: Naming style must be prefix or suffix."
        echo "  (not \"$name_style\")"
        return -1
    fi

    sudo_flag="$5"
    if [ "$sudo_flag" != "" ] && [ "$sudo_flag" != "sudo" ]; then
        echo "$FUNCNAME: copy-with-sudo must be \"\" (empty) or sudo."
        echo "  (not \"$sudo_flag\")"
        return -1
    fi

    # init variables
    filename="$1"
    filebase="$(basename "$filename")"
    filepath="$(dirname  "$filename")"
    if [ "$filepath" == "." ]; then
        filepath=""
    else
        filepath="${filepath}/"
    fi

    backup_path="${2}"

    # check if file exists
    if [ -f "$filename" ] && [ -r "$filename" ]; then
        sudo_flag=""
    else
        if [ "$sudo_flag" != "sudo" ] || \
          sudo [ ! -f "$filename" ]  || sudo [ ! -r "$filename" ]; then
            echo "$FUNCNAME: File \"$filename\" not found or not readable."
            return -2
        fi
    fi

    # check for simplification of name
    filebase="$(_file_backup_simplify_name "$filebase")"
    if [ $? -ne 0 ]; then
        echo "$filebase"
        echo "$FUNCNAME: Stopping because of an error."
        return -1;
    fi

    # check backup path (eventually create it)
    if [ "$backup_path" != "" ] && [ ! -d "$backup_path" ]; then
        echo "creating backup-folder \"$backup_path\""
        mkdir -p "$backup_path"
        if [ $? -ne 0 ]; then
            echo "$FUNCNAME: Stopping because of an error."
            return -1;
        fi
    fi

    # get current extension (prefix or suffix)
    file_date="$(date +"%Y_%m_%d")"

    # check for older backups (simple)
    found=0
    if [ "$name_style" == "prefix" ]; then
        backup_simple="${backup_path}${file_date}__${filebase}"
    else
        backup_simple="${backup_path}${filebase}__${file_date}"
    fi
    if [ -f "${backup_simple}" ]; then
        found=1

        # create new name for older backup
        if [ "$name_style" == "prefix" ]; then
            temp="${backup_path}${file_date}_001__${filebase}"
        else
            temp="${backup_path}${filebase}__${file_date}_001"
        fi

        # inform user
        echo "found other backup"
        echo "  \"${backup_simple}\" ==> \"${temp}\""
        if [ -f "${temp}" ]; then
            echo "$FUNCNAME: Error - \"${temp}\" already exists!"
            return -1;
        fi

        # ask user if continuing
        echo -n "Do you wish to continue ? (Yes/no)"
        if [ "$4" != "-y" ] && [ "$4" != "--yes" ]; then
            read answer
        else
            echo "<auto answer \"yes\">"
            answer="yes"
        fi
        if [ "$answer" != "" ] && \
          [ "$answer" != "y" ] && [ "$answer" != "Y" ] && \
          [ "$answer" != "yes" ]; then

            echo "$FUNCNAME: Aborted."
            return
        fi

        # copy file
        mv "${backup_simple}" "${temp}"
        if [ $? -ne 0 ]; then
            echo "$FUNCNAME: Stopping because of an error."
            return -1;
        fi
    else

        # check for older backups (with numbering)
        if [ "$name_style" == "prefix" ]; then
            temp="${backup_path}${file_date}_[0-9][0-9][0-9]__${filebase}"
            arr=("${backup_path}${file_date}_"[0-9][0-9][0-9]"__${filebase}")
        else
            temp="${backup_path}${filebase}__${file_date}_[0-9][0-9][0-9]"
            arr=("${backup_path}${filebase}__${file_date}_"[0-9][0-9][0-9])
        fi
        if [ "${#arr[*]}" -gt 1 ] || [ "${arr[0]}" != "${temp}" ]; then
            #echo "found other backup(s) - extending backup name"
            found=1
        fi
    fi

    # if backup is simple, just store it
    if [ "$found" -eq 0 ]; then
        echo "creating backup \"${backup_simple}\""
        if [ "$sudo_flag" != "sudo" ]; then
            cp "${filename}" "${backup_simple}"
        else
            sudo cp "${filename}" "${backup_simple}"
            sudo chown "$USER" "${backup_simple}"
        fi
        return
    fi

    # otherwise find a backup name
    cnt="1"
    while [ "$cnt" -lt 1000 ]; do
        if [ "$name_style" == "prefix" ]; then
            temp="${file_date}_$(printf "%03d" $cnt)__${filebase}"
        else
            temp="${filebase}__${file_date}_$(printf "%03d" $cnt)"
        fi
        backup_nr="${backup_path}${temp}"

        if [ ! -e "${backup_nr}" ]; then
            echo "creating backup \"${backup_nr}\""
            if [ "$sudo_flag" != "sudo" ]; then
                cp "${filename}" "${backup_nr}"
            else
                sudo cp "${filename}" "${backup_nr}"
                sudo chown "$USER" "${backup_nr}"
            fi
            return
        fi

        cnt="$(( $cnt + 1 ))"
    done

    echo "$FUNCNAME: Can not create valid backup file :-("
    return -3;
}


#***************************[file_backup_simple]******************************
# 2018 11 08

function file_backup_simple() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME <filename>"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 1 parameter"
        echo "     #1: name of file to be backed up (e.g. \"table.odt\")"
        echo "This function will copy the given file to the backup-folder"
        echo "and prepend it with the current date."
        echo "  (e.g. save \"table.odt\" to \"backup/2018_10_30__table.odt\")"
        echo "If none of the two possible local backup-folders"
        echo "(neither backup nor data) exist, \"backup/\" will be created."

        return
    fi

    # check parameter
    if [ $# -ne 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # init variables
    filename="$1"
    filepath="$(dirname  "$filename")"
    if [ "$filepath" != "/" ]; then
        filepath="${filepath}/"
    fi

    # check if file exists
    if [ ! -f "$filename" ]; then
        echo "$FUNCNAME: File \"$filename\" not found."
        return -2
    fi

    # check for possible backup path
    temp="$(basename "$(readlink -ms "${filepath}")")"
    if [ "$temp" == "backup" ] || [ "$temp" == "data" ]; then
        #echo "already within backup-folder"
        backup_path="${filepath}"

    else
        backup_path="${filepath}backup/"
        if [ ! -d "$backup_path" ]; then
            backup_path2="${filepath}data/"
            if [ -d "$backup_path2" ]; then
                #echo "using \"$backup_path2\" as backup-folder"
                backup_path="$backup_path2"
            fi
        fi
    fi

    _file_backup_base "$filename" "$backup_path" "prefix"
}


#***************************[file_backup_inplace]*****************************
# 2018 11 08

function file_backup_inplace() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME <filename>"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 1 parameter"
        echo "     #1: name of file to be backed up (e.g. \"file.conf\")"
        echo "This function will create a copy the given file within the"
        echo "same folder and extend it with the current date."
        echo "  (e.g. save \"file.conf\" to \"file.conf_2018_10_30\")"

        return
    fi

    # check parameter
    if [ $# -ne 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # init variables
    filename="$1"
    filepath="$(dirname  "$filename")"
    if [ "$filepath" == "." ]; then
        filepath=""
    else
        filepath="${filepath}/"
    fi

    # check if file exists
    if [ ! -f "$filename" ]; then
        echo "$FUNCNAME: File \"$filename\" not found."
        return -2
    fi

    _file_backup_base "$filename" "$filepath" "suffix"
}
