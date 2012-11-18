#!/bin/bash

. ${HOME}/etc/shell.conf

echo "starting..." &> /tmp/pano.log
#lg-sudo --parallel --wait --timeout 1 killall -STOP googleearth-bin &>> /tmp/pano.log

while :; do
  DISPLAY=:0 xiv $@ &>> /tmp/pano.log
  sleep 0.5
done
