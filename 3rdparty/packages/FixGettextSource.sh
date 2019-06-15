#!/usr/bin/env bash
set -euo pipefail
GETTEXT_SRC=$1

#libcroco/cr-statement.c:2661:32: error: format string is not a string literal (potentially insecure) [-Werror,-Wformat-security]
#fprintf (a_fp, str) ;

# gettext wtf? Why U doing this???

sed -i 's/fprintf (a_fp, str)/fprintf (a_fp, "%s", str)/g' $GETTEXT_SRC/libtextstyle/gnulib-local/lib/libcroco/cr-statement.c
sed -i 's/fprintf (a_fp, str)/fprintf (a_fp, "%s", str)/g' $GETTEXT_SRC/libtextstyle/lib/libcroco/cr-statement.c
