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

. ${HOME}/etc/shell.conf
. ${SHINCLUDE}/lg-functions

list=${TOUCHSCRQRF:-/var/www/queries.txt}
out=${EARTH_QUERY}

# if you'd like to tour the moon or mars, replace "earth" in this awk cmd
query=$( awk -F'@' '/^earth/ {print $NF}' $list | shuf -n 1 )
echo q=$query
if [ "${LG_SCREENSAVER}" == "true" ]; then
    echo $query > $out
fi
