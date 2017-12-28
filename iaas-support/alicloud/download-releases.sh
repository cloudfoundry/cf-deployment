#!/usr/bin/env bash

#=========
# $1 cf deployment manifest name. Default to cf-deployment/cf-deployment.yml
# $2 local downloading releases directory. Default to "$(pwd)/cf-deployment-releases".
#=========

RELEASES_ON_LOCAL=$2
if [[ $RELEASES_ON_LOCAL == "" ]]; then
    RELEASES_ON_LOCAL=$(pwd)/releases
    elif [[ $RELEASES_ON_LOCAL == */ ]]; then
        tmp = $RELEASES_ON_LOCAL
        RELEASES_ON_LOCAL= ${tmp%?}
fi

if [[ ! -d "$RELEASES_ON_LOCAL" ]]; then
  mkdir "$RELEASES_ON_LOCAL"
fi

CF_DEPLOYMENT=$1
if [[ $CF_DEPLOYMENT == "" ]]; then
    CF_DEPLOYMENT = cf-deployment/cf-deployment.yml
fi

CF_DEPLOYMENT_LOCAL=${RELEASES_ON_LOCAL}/cf-deployment-local.yml
echo "" > ${CF_DEPLOYMENT_LOCAL}

OLD_IFS="$IFS"
RELEASES=false
RELEASE_NAME=""
cat $CF_DEPLOYMENT | while read LINE
do
    if [[ $LINE == releases: ]]; then
        echo $LINE
        RELEASES=true
    fi

    if [[ $LINE == stemcells: && $RELEASES == true ]]; then
        echo $LINE
        RELEASES=false
    fi

    if [[ ${RELEASES} == true ]]; then
        echo $LINE
        if [[ $LINE == *name:* ]]; then
            IFS="$OLD_IFS"
            read -r -a Words <<< $LINE
            RELEASE_NAME=${Words[2]}
        fi

        if [[ $LINE == *url:* ]]; then
            IFS="$OLD_IFS"
            read -r -a Words <<< $LINE
            wget -c -p -np -nd ${Words[1]} -O ${RELEASES_ON_LOCAL}/${RELEASE_NAME}-release.tgz
            continue
        fi

        if [[ $LINE == *version:* ]]; then
            echo "  $LINE" | sed 's/version: .*/version: latest/g'  >> $CF_DEPLOYMENT_LOCAL
            continue
        fi

        if [[ $LINE == *sha1:* ]]; then
            continue
        fi
    fi
    IFS=
    OIFS=$IFS
    echo $LINE >> $CF_DEPLOYMENT_LOCAL
done
