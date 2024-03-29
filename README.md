# various-scripts-text
Small scripts for various text processing purposes

## t2a

    t2a -- clean strings to use only the ASCII chars: a-z, 0-9 and _.-

    Substitute non-valid characters with _, removes multiple consecutive _'s
    removes leading and trailing whitespace, and translate Danish characters to
    ASCII and output only lowercase.

    Usage:
      >echo "Text" | t2a.sh # Input as piped stream
      >t2a.sh "Text"        # Input as argument

    Examples:
      >t2a.sh "Per Nørgård  - Der Göttliche Tivoli  (1983).flac " # Existing file
      per_noergaard_-_der_gottliche_tivoli_1983.flac

    Dependencies:
      sed, tr, iconv

    Version: 0.1

## pdfcompare

    pdfcompare -- compare rasterized versions of PDF files

    Usage:
      >pdfcompare <pdffile1> <pdffile2>

    Examples:
      >pdfcompare 1.pdf 2.pdf

    Output: image difference metrics and 3-up visualization of the original PDF
    files and their differnce image

    Dependencies:
      convert or pdftoppm, compare, montage, mktemp (uses environment variable
      TMPDIR to find a suitable directory)

