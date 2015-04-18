#!/bin/bash
#
# Pulls a docker image and returns 0 if there a change.
# Returns 1 if there is no change.
DOCKER_IMAGE=$1

BEFORE=$(docker inspect --format='{{.Config.Image}}' ${DOCKER_IMAGE} 2>/dev/null)
docker pull ${DOCKER_IMAGE}
AFTER=$(docker inspect --format='{{.Config.Image}}' ${DOCKER_IMAGE} 2>/dev/null)

if [[ $BEFORE == $AFTER ]]; then
  echo "No updates to ${DOCKER_IMAGE} available"
  exit 1
else
  echo "${DOCKER_IMAGE} updated"
  exit 0
fi
