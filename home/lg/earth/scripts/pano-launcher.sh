#!/bin/bash

. ${HOME}/etc/shell.conf

echo "starting..." &> /tmp/pano.log

while :; do
  DISPLAY=:0 xiv $@ &>> /tmp/pano.log
  sleep 0.5
done
