#!/bin/bash

. ${HOME}/etc/shell.conf

if [[ "${LG_MASTERSLAVE[0]:-slave}" == "master" ]]; then
    # resume Earth procs while killing xiv procs
    lg-sudo --parallel --wait --timeout 1 "killall -CONT googleearth-bin; killall -9 run-xiv.sh; killall -9 xiv"
fi
