#!/bin/bash
# t2a -- clean strings to use only the ASCII chars: a-z, 0-9 and _.-
#
# Substitute non-valid characters with _, removes multiple consequtive _'s
# removes leading and trailing whitespace, and translate Danish characters to
# ASCII and output only lowercase.
#
# Usage:
#   >echo "Text" | t2a.sh # Input as piped stream
#   >t2a.sh "Text"        # Input as argument
#
# Examples:
#   >t2a.sh "Per Nørgård  - Der Göttliche Tivoli  (1983).flac " # Existing file
#   per_noergaard_-_der_gottliche_tivoli_1983.flac
#
# Dependencies:
#   sed, tr, iconv
#
# Version: 0.1
#
# Copyright (C) 2017 Thomas Boevith
#
# License: GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it. There is NO
# WARRANTY, to the extent permitted by law.

function cleanstring {
    if test $# -ge 1; then # If an argument is given then echo as a string
        echo "$@"
    else # else cat the piped stream
        cat -
    fi | sed 's/^[[:blank:]]*//' \
       | sed 's/[[:blank:]]*$//' \
       | sed 's/[^a-Z0-9.-]/_/g' \
       | tr -s '_' \
       | sed 's/æ/ae/Ig' \
       | sed 's/å/aa/Ig' \
       | sed 's/ø/oe/Ig' \
       | tr '[:upper:]' '[:lower:]' \
       | sed 's/^[_]*//' \
       | sed 's/[_]*$//' \
       | iconv -c -f utf-8 -t ascii//translit
}

if test -e "$@"; then
    # If argument is a file: remove underscores around filename and extension
    filename=$(cleanstring "$@")
    extension="${filename##*.}"
    filename="${filename%.*}"
    echo $(cleanstring $filename).$(cleanstring $extension)
else
    # If argument is not a file or a stream is piped to the script
    cleanstring "$@"
fi
