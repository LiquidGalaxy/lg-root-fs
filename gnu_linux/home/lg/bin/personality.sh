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

if [[ $UID -ne 0 ]] ; then
    echo You must run this as root.
    exit 1
fi

# hopefully we were passed some command-line params
while [[ -n "$1" ]]; do
    case "$1" in
        -i)
            shift
            CMD_IFACE=$1
        ;;
        -p)
            shift
            CMD_PERSONA=$1
        ;;
        -o)
            shift
            CMD_OCTET=$1
        ;;
    esac
    shift
done

PERSONA=${CMD_PERSONA}
OCTET=${CMD_OCTET:-42}
IFACE=${CMD_IFACE:-eth0}

if [[ ( $PERSONA -lt 1 ) || ( $PERSONA -gt 8 ) ]] ; then
    echo invalid screen number $PERSONA
    echo please choose a number 1..8
    exit 2
fi

echo lg${PERSONA} > /etc/hostname

rm -f /etc/network/if-up.d/*-lg_alias

cat >/etc/network/if-up.d/${OCTET}-lg_alias <<EOF
#!/bin/sh
PATH=/sbin:/bin:/usr/sbin:/usr/bin
# This file created automatically by $0
# to define an alias where lg systems can communicate
ifconfig ${IFACE}:${OCTET} 10.42.${OCTET}.${PERSONA} netmask 255.255.255.0
# end of file
EOF

chmod 0755 /etc/network/if-up.d/${OCTET}-lg_alias

# we start counting FRAMES at "0"
FRAME=`expr $PERSONA - 1`
echo $FRAME > /lg/frame
# we start counting screens per-frame at 1
#echo $DHCP_LG_SCREENS > /lg/screen

if [ ${OCTET} -ne 42 ]; then
    sed -i -e "s:10\.42\.42\.:10.42.${OCTET}.:g" /etc/hosts
    sed -i -e "s:10\.42\.42\.:10.42.${OCTET}.:g" /etc/hosts.squid
    sed -i -e "s:10\.42\.42\.:10.42.${OCTET}.:g" /etc/iptables.conf
    sed -i -e "s:10\.42\.42\.:10.42.${OCTET}.:g" /etc/ssh/ssh_known_hosts
fi

service hostname start
/etc/network/if-pre-up.d/iptables
/etc/network/if-up.d/${OCTET}-lg_alias
service rsyslog restart &

echo "You should have a persona configured now.

Adjusted the following files (using sed):
  /etc/hosts
  /etc/hosts.squid
  /etc/iptables.conf
  /etc/ssh/ssh_known_hosts
 if you selected a special third octet."

## we need to think about signaling the whole setup when the persona changes
#service lxdm restart
initctl emit --no-wait persona-ok
