#!/bin/bash
# Copyright 2013 Google Inc.
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

. ${HOME}/etc/shell.conf

if [[ "${LG_MASTERSLAVE[0]:-slave}" == "master" ]]; then
    # resume Earth procs while killing xiv procs
    lg-sudo --parallel --wait --timeout 1 "killall -CONT googleearth-bin; killall -9 run-xiv.sh; killall -9 xiv"
fi
