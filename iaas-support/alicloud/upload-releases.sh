#!/usr/bin/env bash

#=========
# $1 release local directory. Default to $(pwd)
# $2 bosh director name
#=========

# upload cf release
RELEASES_ON_LOCAL=$1
if [[ $RELEASES_ON_LOCAL == "" ]]; then
    RELEASES_ON_LOCAL=$(pwd)
    elif [[ $RELEASES_ON_LOCAL == */ ]]; then
        tmp = $RELEASES_ON_LOCAL
        RELEASES_ON_LOCAL= ${tmp%?}
fi

for file_r in ${RELEASES_ON_LOCAL}/*; do
    temp_file=`basename $file_r`
    if [[ $temp_file == *.tgz ]]; then
        if [[ $2 == "" ]]; then
            bosh upload-release ${RELEASES_ON_LOCAL}/$temp_file
        else
            bosh -e $2 upload-release ${RELEASES_ON_LOCAL}/$temp_file
        fi
    fi
done
