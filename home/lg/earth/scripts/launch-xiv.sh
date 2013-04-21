#!/bin/bash
# Copyright 2010 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

. ${HOME}/etc/shell.conf
. ${SHINCLUDE}/lg-functions

COLLECTION=${1:-default}
ME=`basename $0`

if [[ "${LG_MASTERSLAVE[0]:-slave}" == "master" ]]; then
    ${SCRIPDIR}/kill-xiv.sh

    [ ! -d "${XIV_ROOT}/${COLLECTION}" ] && { echo "$ME: Pano collection not found: ${COLLECTION}" >&2; exit 1; }
    [ `ls -x ${XIV_ROOT}/${COLLECTION}/*.ppm | wc -l` -lt 1 ] && { echo "$ME: Pano collection is empty: ${COLLECTION}" >&2; exit 1; }
    PANO_FILE="-browse ${XIV_ROOT}/${COLLECTION}/*.ppm"

    CLIENTS=""
    for SLAVE in ${XIV_SLAVES[*]}; do
        HOSTSTUFF=${SLAVE%%@*}
        SCREENSTUFF=${SLAVE##*@}
        HOST=${HOSTSTUFF%%:*}
        PORT=${HOSTSTUFF##*:}
        CLASS=${SCREENSTUFF%%:*}
        INDEXSTUFF=${SCREENSTUFF##*:}
        INDEX=${INDEXSTUFF%%x*}
        [[ "$INDEXSTUFF" == *x* ]] && VERT=${INDEXSTUFF##*x} || VERT=0
        OFFSET=`echo "${INDEX} * ${LG_SCREEN_HEIGHT} + ${INDEX} * ${XIV_SCREENGAP}" | bc -l`
        echo "HOST: \"$HOST\" PORT: \"$PORT\" CLASS: \"$CLASS\" INDEX: \"$INDEX\" VERT: \"$VERT\" OFFSET: \"$OFFSET\"" >&2
        ssh $HOST "${SCRIPDIR}/run-xiv.sh -winclass $CLASS -listenport $PORT -xoffset $OFFSET -yoffset $VERT -h360 $XIV_OPTS $PANO_FILE" &
        CLIENTS="${CLIENTS} -slavehost ${HOSTSTUFF}"
    done
    echo "CLIENTS: \"$CLIENTS\"" >&2
    ${SCRIPDIR}/run-xiv.sh -spacenav -swapaxes -spsens $XIV_SENSITIVITY $CLIENTS -h360 $XIV_OPTS -geometry ${XIV_FAKE_GEOMETRY} -fakewin $PANO_FILE &

    # pause Earth in the background
    lg-sudo --parallel --wait "killall -STOP googleearth-bin"
fi
