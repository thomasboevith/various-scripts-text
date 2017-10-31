#!/bin/bash
# pdfcompare -- compare rasterized versions of PDF files
#
# Usage:
#   >pdfcompare <pdffile1> <pdffile2>
#
# Examples:
#   >pdfcompare 1.pdf 2.pdf
#
# Dependencies:
#   compare, mktemp (uses environment variable TMPDIR to find a suitable directory)
#
# Version: 0.1
#
# Copyright (C) 2017 Thomas Boevith
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

tmpdir=$(mktemp -d -t pdfcompare.XXXXXXXXXX)

density=72
echo "Rasterizing file: $pdf1"
convert -background white -alpha off -density $density $pdf1 $tmpdir/pdf1_%08d.png
num1=$(find  $tmpdir -type f -name 'pdf1_*.png' | wc -l)

echo "Rasterizing file: $pdf2"
convert -background white -alpha off -density $density $pdf2 $tmpdir/pdf2_%08d.png
num2=$(find  $tmpdir -type f -name 'pdf2_*.png' | wc -l)

if test "$num1" != "$num2"; then
    echo "Error: Number of pages in file: $pdf1 ($num1) is not equal to the number of pages ($num2) in file: $pdf2"
    /bin/rm -rf $tmpdir
    exit 1
else
    let totnum=$num1-1
    echo "Number of pages to compare: $totnum"
fi

for i in $(seq -f%08g 0 $totnum); do
    metrics=(AE PAE PSNR MAE MSE RMSE MEPP FUZZ NCC)
    results=()
    echo -n "Page $i "
    for metric in ${metrics[@]}; do
        compare -metric $metric $tmpdir/pdf1_$i.png $tmpdir/pdf2_$i.png $tmpdir/diff_$i.png 2> $tmpdir/$metric.$i.txt
        echo -n "$metric=$(cat $tmpdir/$metric.$i.txt) "
    done
    echo
done

/bin/rm -rf $tmpdir
