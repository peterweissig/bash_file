#!/bin/bash



#***************************[line break]**************************************

# 2025 03 17
function file_linebreak_dos() {
    sed --in-place --null-data --regexp-extended \
      --expression='s/(\r?\n|\r\n?)/\r\n/g' "$@"
}

# 2025 03 17
function file_linebreak_unix() {
    sed --in-place --null-data --regexp-extended \
      --expression='s/(\r?\n|\r\n?)/\n/g' "$@"
}
