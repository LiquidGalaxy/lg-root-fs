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

# This option prevents Earth from batching tile requests
DRIVER_ARGS="-sConnection/disableRequestBatching=true"

if [ "${LG_MASTERSLAVE[${ME_SCREEN:-0}]}" == "master" ]; then
    MASTER="true"
    DRIVER_ARGS="${DRIVER_ARGS} -sViewSync/send=true"
else
    MASTER="false"
    DRIVER_ARGS="${DRIVER_ARGS} -sViewSync/receive=true"
fi
lg-log "master/slave: ${LG_MASTERSLAVE[${ME_SCREEN:-0}]} M=${MASTER}"

MYIPALIAS="$( awk '/^ifconfig/ {print $3}' /etc/network/if-up.d/*-lg_alias )"
VSYNCCHOP="${MYIPALIAS%.*}"
VSYNCHOST="10.42.${VSYNCCHOP##*.}.255"
VSYNCPORT="$EARTH_PORT"

# Adjust ViewSync packet destination if using a ViewSync relay
if [[ "$VSYNC_RELAY" == "true" ]] && [[ "$MASTER" == "true" ]]; then
    VSYNCHOST=127.0.0.1
    VSYNCPORT=$((${VSYNCPORT}-1))
fi

DRIVER_ARGS="${DRIVER_ARGS} -sViewSync/hostname=$VSYNCHOST -sViewSync/port=$VSYNCPORT"

FOV=${LG_HORIZFOV[${ME_SCREEN:-0}]}
YAW=${LG_YAWOFFSET[${ME_SCREEN:-0}]}
PITCH=${LG_PITCHOFFSET[${ME_SCREEN:-0}]}
ROLL=${LG_ROLLOFFSET[${ME_SCREEN:-0}]}

DRIVER_ARGS="${DRIVER_ARGS} \
-sViewSync/yawOffset=$YAW \
-sViewSync/pitchOffset=$PITCH \
-sViewSync/rollOffset=$ROLL \
-sViewSync/horizFov=$FOV"

# Enable input mechanisms for master
if [[ "$MASTER" == "true" ]]; then
  DRIVER_ARGS="${DRIVER_ARGS} \
-sViewSync/queryFile=$EARTH_QUERY \
-sSpaceNavigator/device=$SPACENAVDEV \
-sSpaceNavigator/gutterValue=0.1 \
-sSpaceNavigator/sensitivityPitch=0.01 \
-sSpaceNavigator/sensitivityRoll=0.001 \
-sSpaceNavigator/sensitivityYaw=0.0035 \
-sSpaceNavigator/sensitivityX=0.25 \
-sSpaceNavigator/sensitivityY=0.25 \
-sSpaceNavigator/sensitivityZ=0.02 \
-sSpaceNavigator/zeroPitch=0.0 \
-sSpaceNavigator/zeroRoll=0.0 \
-sSpaceNavigator/zeroYaw=0.0 \
-sSpaceNavigator/zeroX=0.0 \
-sSpaceNavigator/zeroY=0.0 \
-sSpaceNavigator/zeroZ=0.0"
  
fi

echo $DRIVER_ARGS
