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

if [[ "${LG_MASTERSLAVE[0]:-slave}" == "master" ]]; then
    echo "[$( date )] launch-mplayer" >${HOME}/log/launch-mplayer.log
    lg-sudo "pkill '(run-earth-bin|googleearth-bin|mplayer)'"
    pkill -f viewsyncrelay.pl
    lg-run-bg ${HOME}/bin/lg-pls-gen /media/video
    pkill -u $(id -u) socat
    VSYNCBYTES=12
    MULTIPLIER=0
    socat -b $VSYNCBYTES -u udp4-listen:${MPLAYER_PORT},reuseaddr,bind=127.255.255.255 udp4-datagram:10.42.${LG_OCTET}.255:$((${MPLAYER_PORT}+${MULTIPLIER})),broadcast &
    MULTIPLIER=2
    socat -b $VSYNCBYTES -u udp4-listen:${MPLAYER_PORT},reuseaddr,bind=127.255.255.255 udp4-datagram:10.42.${LG_OCTET}.255:$((${MPLAYER_PORT}+${MULTIPLIER})),broadcast &
    sleep 1
    lg-run-bg ${HOME}/bin/launchmplayer 8 ${XDG_VIDEOS_DIR}/default >>${HOME}/log/launch-mplayer.log 2>&1
fi
