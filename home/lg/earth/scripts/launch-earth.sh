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

if [[ "${FRAME_NO}" == "0" ]]; then
    ${SCRIPDIR}/pano-kill.sh
    lg-sudo "pkill '(run-earth-bin|googleearth-bin|mplayer)'"
    pkill -f viewsyncrelay.pl 
    pkill -u $(id -u) socat
    sleep 1

    ### viewsyncrelay setup
    if [[ "${VSYNC_RELAY}" == "true" ]]; then
        m4 \
            -D__LG_OCTET__=${LG_OCTET} \
            -D__EARTH_PORT__=${EARTH_PORT} \
            -D__INPUT_PORT__=$((${EARTH_PORT}-1)) \
            ${SHCONFDIR}/actions-template.m4 >${SHCONFDIR}/actions.yml

        for FILE in ${HOME}/etc/actions.d/*.yml; do
            cat $FILE >> ${SHCONFDIR}/actions.yml
        done

        viewsyncrelay.pl ${SHCONFDIR}/actions.yml &
    fi
    ###


    lg-run-bg ${SCRIPDIR}/run-earth-bin.sh
fi
