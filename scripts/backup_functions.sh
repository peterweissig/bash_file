#!/bin/bash

#***************************[backup]******************************************
# 2018 10 29

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
        echo "If neither of the two possible local backup-folders"
        echo "(backup nor data) exist, \"backup/\" will be created."

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
    filebase="$(basename "$filename")"
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

    # check backup path (eventually create it)
    backuppath="${filepath}backup/"
    if [ ! -d "$backuppath" ]; then
        backuppath2="${filepath}data/"
        if [ -d "$backuppath2" ]; then
            echo "using \"$backuppath\" as backup-folder"
            backuppath="$backuppath2"
        else
            echo "creating backup-folder \"$backuppath\""
            mkdir -p "$backuppath"
            if [ $? -ne 0 ]; then
                echo "$FUNCNAME: Stopping because of an error."
                return -1;
            fi
        fi
    fi

    # get current prefix
    fileprefix="$(date +"%Y_%m_%d_")"

    # check for older backups (simple)
    found=0
    backup_simple="${backuppath}${fileprefix}_${filebase}"
    if [ -f "${backup_simple}" ]; then
        found=1
        temp="${backuppath}${fileprefix}001__${filebase}"

        echo "found other backup \"${backup_simple}\""
        echo "it is going to be renamed to \"${temp}\""
        if [ -f "${temp}" ]; then
            echo "$FUNCNAME: Error - \"${temp}\" already exists!"
            return -1;
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

        # copy file
        mv "${backup_simple}" "${temp}"
        if [ $? -ne 0 ]; then
            echo "$FUNCNAME: Stopping because of an error."
            return -1;
        fi
    else

        # check for older backups (with numbering)
        temp="${backuppath}${fileprefix}[0-9][0-9][0-9]__${filebase}"
        arr=("${backuppath}${fileprefix}"[0-9][0-9][0-9]"__${filebase}")
        echo "arr= \"${arr[*]}\""
        if [ "${#arr[*]}" -gt 1 ] || [ "${arr[0]}" != "${temp}" ]; then
            found=1
        fi
    fi

    # if backup is simple, just store it
    if [ "$found" -eq 0 ]; then
        echo "creating backup \"${backup_simple}\""
        cp "${filename}" "${backup_simple}"
        return
    fi

    # otherwise find a backup name
    cnt="1"
    while [ "$cnt" -lt 1000 ]; do
        temp="${fileprefix}$(printf "%03d" $cnt)__${filebase}"
        backup_nr="${backuppath}${temp}"

        if [ ! -f "${backup_nr}" ]; then
            echo "creating backup \"${backup_nr}\""
            cp "${filename}" "${backup_nr}"
            return
        fi

        cnt="$(( $cnt + 1 ))"
    done

    echo "$FUNCNAME: Can not create valid backup file :-("
    return -3;
}
