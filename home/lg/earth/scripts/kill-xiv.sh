#!/bin/bash

. ${HOME}/etc/shell.conf

if [[ "${LG_MASTERSLAVE[0]:-slave}" == "master" ]]; then
    # resume Earth procs while killing xiv procs
    lg-sudo --parallel "killall -CONT googleearth-bin; killall -9 pano-launcher.sh; killall -9 xiv"
fi
