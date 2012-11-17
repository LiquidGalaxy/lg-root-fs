#!/bin/bash

. ${HOME}/etc/shell.conf

lg-sudo-bg killall -STOP googleearth-bin

while :; do
  DISPLAY=:0 xiv $@
  sleep 0.5
done
