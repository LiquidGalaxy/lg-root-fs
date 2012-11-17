#!/bin/bash

. ${HOME}/etc/shell.conf

lg-run "killall -9 pano-launcher.sh"
lg-run-bg "killall -9 xiv"
lg-sudo-bg "killall -CONT googleearth-bin"
