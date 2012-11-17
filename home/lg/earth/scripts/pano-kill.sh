#!/bin/bash

. ${HOME}/etc/shell.conf

if [[ "${FRAME_NO}" == "0" ]]; then
    lg-run "killall -9 pano-launcher.sh"
    lg-run-bg "killall -9 xiv"
    lg-sudo-bg "killall -CONT googleearth-bin"
fi
