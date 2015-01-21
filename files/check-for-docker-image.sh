#!/bin/bash

parts=(${1//\// })

REPO=${parts[0]}
IMAGE=${parts[1]}
TAG=$2

REPLY=$(curl -X GET https://$REPO/v1/repositories/$IMAGE/tags/$TAG)

if [[ $REPLY != \"* ]]
then
    REPLY=$(curl -X GET http://$REPO/v1/repositories/$IMAGE/tags/$TAG)
fi

if [[ $REPLY != \"* ]]
then
    exit 1
fi

REPO_IMAGE_ID="${REPLY//\"}"
CURRENT_IMAGE_ID=$(docker images --no-trunc | grep ^$REPO/$IMAGE | grep " $TAG " | awk '{ print $3 }')

if [[ $REPO_IMAGE_ID != $CURRENT_IMAGE_ID ]]
then
    exit 1
fi

exit 0
