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

echo "$0: $( date )"
echo "DISPLAY = \"$DISPLAY\"."
echo "DISPLAY_SCREEN = \"${DISPLAY##*\.}\"."
echo "MY FRAME = \"${FRAME_NO}\"."

# basic items for any screen/any window manager
xsetroot -solid black &
xset dpms 0 0 0 -dpms s blank s noexpose s 0 0 &
xinput set-int-prop "3Dconnexion SpaceNavigator" "Device Enabled" 8 0 &
xhost +local: &
if [ -x "${LG_MEDIA_MNT}/backgrounds" -a -f "${LG_MEDIA_MNT}/backgrounds/lg-bg-noframe.png" ]; then
    USE_BG_DIR="${LG_MEDIA_MNT}/backgrounds"
else
    USE_BG_DIR="${XDG_PICTURES_DIR}/backgrounds"
fi

nitrogen --set-${LG_BG_MODE} ${USE_BG_DIR}/${LG_BG_NAMEBASE}-${LG_BG_NAMEFIN}.${LG_BG_EXT} &

if [[ "${LG_MASTERSLAVE[0]:-slave}" == "master" ]]; then
    if [ "${TOUCHSCREEN}" == "true" ]; then
        lg-log "launching kiosk browser on frame: \"${FRAME_NO}\""
        x-www-browser --user-data-dir='/tmp/chromium-browser-iface' --enable-webgl --enable-accelerated-compositing --disable-dev-tools --disable-logging --disable-metrics --disable-metrics-reporting --disable-breakpad --disable-default-apps --disable-extensions --disable-java --disable-plugins --disable-session-storage --disable-translate --force-compositing-mod --no-first-run --incognito --kiosk "${LG_IFACE_BASE}/${LG_IFACE_INDEX}" &
    fi
    
    lg-log "executing galaxy launcher"
    ${SCRIPDIR}/launch-galaxy.sh &
    sleep 60
    lg-log "performing one-shot lowmem kill"
    lg-lowmem-kill
  
elif [[ "${LG_MASTERSLAVE[0]:-slave}" == "slave" ]]; then
    # slaves just wait for master
    # we need to add a method for slave instances to "notify" the master that they have started
    lg-log "slave node with frame_no: \"${FRAME_NO}\", ready"
else
    # will wait up to 9 seconds in increments of 3
    # to get an IP
    IP_WAIT=0
    
    nitrogen --set-tiled ${USE_BG_DIR}/${LG_BG_BASENAME}-noframe.${LG_BG_EXT} &
      
    while [[ $IP_WAIT -le 9 ]]; do
        PRIMARY_IP="$(ip addr show dev eth0 primary | awk '/inet\ / { print $2}')"
        PRIMARY_MAC="$(ip link show eth0 | awk '/link\/ether\ / { print $2 }' )"
        if [[ -z "$PRIMARY_IP" ]]; then
            let IP_WAIT+=3
            sleep 3
        else
            break
        fi
    done
    
    # notify user
    zenity --width=500 --error --title="Please Assign Personality" \
    --text="<span size=\"x-large\"> \"Personality\" assignment is <b>essential</b>.
  
My primary IP address: \"${PRIMARY_IP}\"
My primary MAC address: \"${PRIMARY_MAC}\"
    
Utilize ${HOME}/bin/personality.sh with root priv.</span>"
fi
