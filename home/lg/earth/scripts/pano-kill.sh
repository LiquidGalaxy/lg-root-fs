#!/bin/bash

. ${HOME}/etc/shell.conf

if [[ "${LG_MASTERSLAVE[0]:-slave}" == "master" ]]; then
    lg-run --parallel "killall -9 pano-launcher.sh; killall -9 xiv"

    # resume Earth procs
    lg-sudo --parallel killall -CONT googleearth-bin
fi
