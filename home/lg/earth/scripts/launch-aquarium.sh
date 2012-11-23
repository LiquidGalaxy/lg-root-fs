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

LOGFILE=${HOME}/log/launch-aquarium.log

if [[ "${LG_MASTERSLAVE[0]:-slave}" == "master" ]]; then
    echo "[$( date )] launch-aquarium" > $LOGFILE
    {
    lg-sudo "pkill '(run-earth-bin|googleearth-bin|mplayer)'"
    pkill -f viewsyncrelay.pl
    pkill -u $(id -u) socat
    sleep 1
    ${HOME}/bin/lg-run-bg ${HOME}/bin/lg-chromium webglsamples/aquarium/aquarium.html '100%25%20HTML5%2C%20WebGL%20and%20JavaScript.%208%20machines%20running%20Chrome%20using%20WebSockets%2C%20node.js%20and%20socket.io%20to%20stay%20in%20sync.'
    } >>$LOGFILE 2>&1
fi
