#!/bin/bash
# pdfcompare -- compare rasterized versions of PDF files
#
# Usage:
#   >pdfcompare <pdffile1> <pdffile2>
#
# Examples:
#   >pdfcompare 1.pdf 2.pdf
#
# Output: image difference metrics and 3-up visualization of the original PDF
# files and their differnce image
#
# Dependencies:
#   convert or pdftoppm, compare, montage, mktemp (uses environment variable
#   TMPDIR to find a suitable directory)
#
# Version: 0.4
#
# Copyright (C) 2022 Thomas Boevith
#
# License: GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it. There is NO
# WARRANTY, to the extent permitted by law.

pdf1="$1"
pdf2="$2"

if ( (test "$pdf1" == "") || (test "$pdf2" == "") ); then
    echo "Usage: $0 <pdffile1> <pdffile2>"
    exit 1
fi

for f in "$pdf1" "$pdf2"; do
    if test ! -e "$f"; then
        echo "$(basename $0): cannot access $f: No such file"
        exit 1
    fi
done
for f in "$pdf1" "$pdf2"; do
    ftype="$(file -b $f)"
    if [ "${ftype%%,*}" != "PDF document" ]; then
        echo "$(basename $0): file is not a PDF file: $f ... exiting"
        exit 1
    fi
done

tmpdir=$(mktemp --directory /tmp/pdfcompare.XXXXXXXX)
if test ! -d "$tmpdir"; then
    echo "$(basename $0): cannot access temporary directory '$tmpdir': No such directory"
    exit 1
fi

useimagemagick=0
usepdftoppm=1

if test "$useimagemagick" -eq 1; then
    density=72
    echo "Rasterizing file: $pdf1"
    convert -background white -alpha off -density $density $pdf1 $tmpdir/pdf1_%08d.png

    echo "Rasterizing file: $pdf2"
    convert -background white -alpha off -density $density $pdf2 $tmpdir/pdf2_%08d.png
elif test "$usepdftoppm" -eq 1; then
    density=72
    echo "Rasterizing file: $pdf1"
    pdftoppm -png "$pdf1" "$tmpdir/pdf1"

    echo "Rasterizing file: $pdf2"
    pdftoppm -png "$pdf2" "$tmpdir/pdf2"
else
    exit 1
fi
num1=$(find  $tmpdir -type f -name 'pdf1*.png' | wc -l)
num2=$(find  $tmpdir -type f -name 'pdf2*.png' | wc -l)

if test "$num1" != "$num2"; then
    echo "Error: Number of pages in file: $pdf1 ($num1) is not equal to the number of pages ($num2) in file: $pdf2"
    /bin/rm -rf $tmpdir
    exit 1
else
    let totnum=$num1-1
    echo "Number of pages to compare: $totnum"
fi

i=1
for pdf1 in $tmpdir/pdf1*.png; do
    num=$(echo "$pdf1" | grep -Eo '\-[0-9]{1,}.png$')
    num=${num:1:-4}
    pdf1basename=$(basename $pdf1)
    pdf2=$tmpdir/pdf2${pdf1basename#pdf1}
    diff=$tmpdir/diff${pdf1basename#pdf1}
    metrics=(AE PAE PSNR MAE MSE RMSE MEPP FUZZ NCC)
    results=()
    echo -n "Page $i "
    for metric in ${metrics[@]}; do
        metricfile=$tmpdir/metric${pdf1basename#pdf1}
        compare -metric $metric $pdf1 $pdf2 $diff 2> $metricfile
        montage $pdf1 $pdf2 $diff -tile x1 -geometry +5+5 ./diff-pdfcompare-page-${num}.png
        echo -n "$metric=$(cat $metricfile) "
    done
    echo
    i=$((i+1))
done

if test -d "$tmpdir"; then
  rm -r $tmpdir  # Cleaning up
fi
