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
    if [ $pid -ne $$ ] && [ $( ps -o ppid= $pid ) -ne $$ ]; then kill -9 $pid; fi
done

pkill -u ${ME_USER_NUM} googleearth-bin
sleep 2

# execute thyself as each Screen user
if [[ "${ME_USER}" == "lg" ]]; then
    for screen in /home/lgS*; do
        if [[ -d ${screen} ]]; then
            screennum=${screen##/home/lgS}
            lg-log "launching \"$ME\" for my screen \"${screennum}\""
            sudo -u lgS${screennum} -H ME_SCREEN=${screennum} ${SCRIPDIR}/${ME} ${@} &
            unset screennum
        fi
    done
fi

[[ -n "${DISPLAY}" ]] || export DISPLAY=:0.0
SANITIZE_D=${DISPLAY//:/}
[ -n "${SANITIZE_D##*\.}" -a ${SANITIZE_D##*\.} -ne 0 ] && export SCREEN_NO=${SANITIZE_D##*\.}
export __GL_SYNC_TO_VBLANK=1  # broken for nvidia when rotating scree

cd ${SCRIPDIR} || exit 1
lg-log "running write-drivers - S:\"${ME_SCREEN:-0}\"."
./write-drivers-ini.sh

if [ $FRAME_NO -eq 0 ] ; then
    if [ ${ME_SCREEN} -eq 0 ]; then
        WIN_NAME="ge-ts"
    else
        WIN_NAME="ge-${ME_USER}"
    fi
    DIR=master
else
    WIN_NAME="ge-${ME_USER}"
    DIR=slave
fi

MYCFGDIR="${CONFGDIR}/${DIR}"
# build the configuration file
m4 -I${MYCFGDIR} ${MYCFGDIR}/GECommonSettings.conf.m4 > ${MYCFGDIR}/$( basename `readlink ${MYCFGDIR}/GECommonSettings.conf.m4` .m4 )
# prep for copy if needed
mkdir -p -m 775 ${HOME}/.config/Google
mkdir -p -m 700 ${HOME}/.googleearth
# copying files AND potentially symlinks here
cp -a ${MYCFGDIR}/*        ${HOME}/.config/Google/
cp -a ${LGKMLDIR}/${DIR}/* ${HOME}/.googleearth/
# expand the ##HOMEDIR## var in configs
sed -i -e "s:##HOMEDIR##:${HOME}:g" ${HOME}/.config/Google/*.conf
# expand vars (may contain ":" and "/") in kml files
sed -i \
  -e "s@##LG_PHPIFACE##@${LG_PHPIFACE}@g" \
  -e "s@##EARTH_KML_UPDATE_URL##@${EARTH_KML_UPDATE_URL[${ME_SCREEN:-0}]}@g" \
  -e "s@##CHECK_REF##@$(cat /etc/hostname)-${ME_SCREEN:-0}@g" ${HOME}/.googleearth/*.kml

while true ; do
    if [[ "$DIR" == "master" ]]; then
        lg-sudo pkill googleearth-bin
    fi
    [ -w $SPACENAVDEV ] && ${HOME}/bin/led-enable ${SPACENAVDEV} 1

    cd ${BUILDDIR}/${EARTH_BUILD}
    rm -f ${HOME}/.googleearth/Cache/db* # important: otherwise we get random broken tiles
    rm -rf ${HOME}/.googleearth/Temp/*
    rm -f ${EARTH_QUERY:-/tmp/query.txt}
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
    #./googleearth -style cleanlooks --fullscreen -font "-adobe-helvetica-bold-r-normal-*-${LG_FONT_SIZE}-*-*-*-p-*-iso8859-1"
    LD_PRELOAD=/usr/lib/libfreeimage.so.3 ./googleearth -style GTK+ &
    lg-proc-watch -p ${ME_USER} -b googleearth-bin -n "Google Earth" -c ${WIN_NAME} -k 20

    [ -w $SPACENAVDEV ] && ${HOME}/bin/led-enable ${SPACENAVDEV} 0
    sleep 3
done
