#!/bin/bash
#
# Author: Francesco Montorsi
# RCS-ID: $Id: acregen.sh 505 2007-03-31 10:31:46Z frm $
# Creation date: 14/9/2005
# Modification date: 12/5/2008 (Michal Bliznak)
#
# A simple script to generate the configure script for a wxCode component
# Some features of this version:
# - automatic test for aclocal version
# - able to be called from any folder
#   (i.e. you can call it typing 'build/acregen.sh', not only './acregen.sh')


# called when an old version of aclocal is found
function aclocalold()
{
    echo "Your aclocal version is  $aclocal_maj.$aclocal_min.$aclocal_rel"
    echo "Your automake installation is too old; please install automake >= $aclocal_minimal_maj.$aclocal_minimal_min.$aclocal_minimal_rel"
    echo "You can download automake from ftp://sources.redhat.com/pub/automake/"
    exit 1
}

# first check if we have an ACLOCAL version recent enough
aclocal_verfull=$(aclocal --version)
aclocal_maj=`echo $aclocal_verfull | sed 's/aclocal (GNU automake) \([0-9]*\).\([0-9]*\).\([0-9]*\).*/\1/'`
aclocal_min=`echo $aclocal_verfull | sed 's/aclocal (GNU automake) \([0-9]*\).\([0-9]*\).\([0-9]*\).*/\2/'`
aclocal_rel=`echo $aclocal_verfull | sed 's/aclocal (GNU automake) \([0-9]*\).\([0-9]*\).\([0-9]*\).*/\3/'`

aclocal_minimal_maj=1
aclocal_minimal_min=9
aclocal_minimal_rel=6

if [[ $(expr $aclocal_maj \> $aclocal_minimal_maj) = "1" ]]; then
    majok="1"; minok="1"; relok="1";
else
    majok=$(expr $aclocal_maj \>= $aclocal_minimal_maj);

    if [[ $(expr $aclocal_min \> $aclocal_minimal_min) = "1" ]]; then

        minok="1"; relok="1";
    else
        minok=$(expr $aclocal_min \>= $aclocal_minimal_min);
	relok=$(expr $aclocal_rel \>= $aclocal_minimal_rel);
    fi
fi

if [[ "$majok" = "0" ]]; then aclocalold; fi
if [[ "$majok" = "1" && "$minok" = "0" ]]; then aclocalold; fi
if [[ "$majok" = "1" && "$minok" = "1" && "$relok" = 0 ]]; then aclocalold; fi

# we can safely proceed
me=$(basename $0)
path=${0%%/$me}        # path from which the script has been launched
current=$(pwd)
cd $path

# NOTE: we add /usr/local/share/aclocal include path to the "aclocal" call
#       because usually bakefile gets installed into /usr/local prefix but
#       by default aclocal only looks into /usr/share/aclocal
#       (you can test this doing `aclocal --print-ac-dir`)
# aclocal -I /usr/local/share/aclocal && autoconf && mv configure ..
aclocal && autoconf && mv configure ..
cd $current
