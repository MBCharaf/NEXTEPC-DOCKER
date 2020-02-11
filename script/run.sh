#!/bin/bash
CONTAINER=${1:-epc}
APP=${2:-nextepc}
CONF=${3:-nextepc.conf}
CONFIGPATH=${4:-~/.config/nextepc}

docker cp $CONFIGPATH/$CONF  $CONTAINER:/nextepc/install/etc/nextepc/
docker exec  -it $CONTAINER /bin/sh -c "./$APP/nextepc-epcd"