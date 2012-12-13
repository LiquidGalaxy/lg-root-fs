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

lg-log "running at $(date +%s)"
# know thyself
ME="$( basename $0 )"
ME_USER="$( id -un )"
ME_USER_NUM="$( id -u )"

# kill any other copies
ME_PIDS="$( pgrep -u ${ME_USER_NUM} run-earth-bin )"
for pid in ${ME_PIDS}; do
    # do not kill thyself or thy children
    if [ "$pid" -ne $$ ] && [ "$( ps -o ppid= $pid )" -ne $$ ]; then kill -9 $pid; fi
done

pkill -u ${ME_USER_NUM} googleearth-bin
sleep 2

# execute thyself as each Screen user
if [[ "${ME_USER}" == "lg" && ${screen##/home/lgS} < ${LG_SCREEN_COUNT} ]]; then
    for screen in /home/lgS*; do
        if [[ -d "${screen}" ]]; then
            screennum=${screen##/home/lgS}
            lg-log "launching \"$ME\" for my screen \"${screennum}\""
            sudo -u lgS${screennum} -H ME_SCREEN=${screennum} ${SCRIPDIR}/${ME} ${@} &
            unset screennum
        fi
    done
fi

[[ -n "${DISPLAY}" ]] || export DISPLAY=:0.0
SANITIZE_D=${DISPLAY//:/}
[ -n "${SANITIZE_D##*\.}" -a "${SANITIZE_D##*\.}" -ne 0 ] && export SCREEN_NO=${SANITIZE_D##*\.}
export __GL_SYNC_TO_VBLANK=1  # broken for nvidia when rotating screen

cd ${SCRIPDIR} || { lg-log "could not cd into script dir, \"${SCRIPDIR}\"."; exit 1; }
lg-log "running write-drivers - S:\"${ME_SCREEN:-0}\"."
DRIVER_ARGS=`ME_SCREEN=${ME_SCREEN} ./write-drivers-ini.sh`

DIR="${LG_MASTERSLAVE[${ME_SCREEN:-0}]}"
WIN_NAME="${EARTH_WINNAME[${ME_SCREEN:-0}]}"

MYCFGDIR="${CONFGDIR}/${DIR}"

while true ; do
    if [[ "$DIR" == "master" ]]; then
        lg-sudo pkill googleearth-bin
        [ -w "${SPACENAVDEV}" ] && ${HOME}/bin/led-enable ${SPACENAVDEV} 1
    fi

    # clean up cache, temp files
    cd ${BUILDDIR}/${EARTH_BUILD[${ME_SCREEN:-0}]}
    rm -f ${HOME}/.googleearth/Cache/db* # important: otherwise we get random broken tiles
    rm -rf ${HOME}/.googleearth/Temp/*
    rm -f ${EARTH_QUERY:-/tmp/query.txt}

    # build the configuration files
    m4 -I${MYCFGDIR} ${MYCFGDIR}/GECommonSettings.conf.m4 > ${MYCFGDIR}/GECommonSettings.conf
    m4 -D__HOMEDIR__=${HOME} ${MYCFGDIR}/GoogleEarthPlus.conf.m4 > ${MYCFGDIR}/GoogleEarthPlus.conf

    # prep for move if needed
    mkdir -p -m 775 ${HOME}/.config/Google
    mkdir -p -m 700 ${HOME}/.googleearth

    # move configs into place
    cp -a ${LGKMLDIR}/${DIR}/* ${HOME}/.googleearth/
    mv ${MYCFGDIR}/GECommonSettings.conf ${HOME}/.config/Google/
    mv ${MYCFGDIR}/GoogleEarthPlus.conf ${HOME}/.config/Google/

    # expand vars (may contain ":" and "/") in kml files
    sed -i \
        -e "s@##LG_IFACE_BASE##@${LG_IFACE_BASE}@g" \
        -e "s@##EARTH_KML_UPDATE_URL##@${EARTH_KML_UPDATE_URL[${ME_SCREEN:-0}]}@g" \
        -e "s@##EARTH_KML_SYNC_TAG##@${EARTH_KML_SYNC_TAG[${ME_SCREEN:-0}]}@g" ${HOME}/.googleearth/*.kml

    # shove mouse over to touchscreen interface
    if [[ "$DIR" == "master" ]]; then
        # use the touchscreen
        DISPLAY=:0 xdotool mousemove -screen 1 1910 1190
    else
        # lock the keyboard and mouse
        #DISPLAY=:0 xtrlock & DISPLAY=:0 xdotool mousemove -screen 0 1190 1910
        DISPLAY=:0 xdotool mousemove -screen 0 1190 1910
    fi

    lg-log "running earth"
    LD_PRELOAD=/usr/lib/libfreeimage.so.3 ./googleearth -style GTK+ ${DRIVER_ARGS} &
    lg-proc-watch -u ${ME_USER} -b googleearth-bin -n "Google Earth" -c ${WIN_NAME} -k 20

    if [[ "$DIR" == "master" ]]; then
        [ -w "${SPACENAVDEV}" ] && ${HOME}/bin/led-enable ${SPACENAVDEV} 0
    fi

    sleep 3
done
