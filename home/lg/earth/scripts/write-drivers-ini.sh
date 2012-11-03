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

# Source the common shell configuration
# initializes some variables, like FRAME_NO
. ${HOME}/etc/shell.conf
. ${SHINCLUDE}/lg-functions

if [ "${LG_MASTERSLAVE[${ME_SCREEN:-0}]}" == "master" ]; then
    MASTER="true"
    SLAVE="false"
else
    MASTER="false"
    SLAVE="true"
fi
lg-log "master/slave: ${LG_MASTERSLAVE[${ME_SCREEN:-0}]} M=${MASTER} S=${SLAVE}"

MYIPALIAS="$( awk '/^ifconfig/ {print $3}' /etc/network/if-up.d/*-lg_alias )"
VSYNCCHOP="${MYIPALIAS%.*}"
VSYNCHOST="10.42.${VSYNCCHOP##*.}.255"
VSYNCPORT="$EARTH_PORT"

# Adjust ViewSync packet destination if using a ViewSync relay
if [[ "$VSYNC_RELAY" == "true" ]] && [[ "$MASTER" == "true" ]]; then
    VSYNCHOST=127.0.0.1
    VSYNCPORT=$((${VSYNCPORT}-1))
fi

# Disable input mechanisms for slaves
if [[ "$VSYNC_RELAY" != "true" ]]; then
    SPACENAVDEV=";"
    EARTH_QUERY=";"
fi

FOV=${LG_HORIZFOV[${ME_SCREEN:-0}]}
YAW=${LG_YAWOFFSET[${ME_SCREEN:-0}]}
PITCH=${LG_PITCHOFFSET[${ME_SCREEN:-0}]}
ROLL=${LG_ROLLOFFSET[${ME_SCREEN:-0}]}

cd ${EARTHDIR} || exit 1

echo "MASTER: $MASTER"
echo "SLAVE: $SLAVE"
echo "VSYNCHOST: $VSYNCHOST"
echo "VSYNCPORT: $VSYNCPORT"
echo "YAW: $YAW"
echo "PITCH: $PITCH"
echo "ROLL: $ROLL"
echo "FOV: $FOV"
echo "NAV: $SPACENAVDEV"
echo "QUERY: $EARTH_QUERY"

## THIS MUST BE HANDLED BEFORE NOW
#chmod 644 builds/latest/drivers.ini

# remember the navigator device AND query file will have "/"
cat ${EARTHDIR}/config/drivers_template.ini |\
  sed -e "s/##MASTER##/$MASTER/" \
  -e "s/##SLAVE##/$SLAVE/" \
  -e "s/##VSYNCHOST##/$VSYNCHOST/" \
  -e "s/##VSYNCPORT##/$VSYNCPORT/" \
  -e "s/##YAW##/$YAW/" \
  -e "s/##PITCH##/$PITCH/" \
  -e "s/##ROLL##/$ROLL/" \
  -e "s/##FOV##/$FOV/" \
  -e "s:##EARTH_QUERY##:$EARTH_QUERY:" \
  -e "s:##NAV##:$SPACENAVDEV:" > ${BUILDDIR}/${EARTH_BUILD}/drivers.ini
