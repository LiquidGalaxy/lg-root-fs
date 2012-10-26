#!/usr/bin/python
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

"""
Executes applied command periodically while Space Navigator isn't touched.
It can be used to add screensaver-ish application to Liquid Galaxy.
Can also use dpms to put displays to sleep after a longer period of neglect.
"""

import fcntl
import os
import sys
import time
import datetime
import re
import statsd
from statsd import StatsdTimer

if os.path.isfile('/etc/debian_chroot'):
  myname = open("/etc/debian_chroot","r").read()
  myname = myname.rstrip('\n')
else:
  myname = os.uname()[1]

statsd.init_statsd({'STATSD_HOST': 'lg-head', 'STATSD_BUCKET_PREFIX': "%s" % myname}
timer = statsd.StatsdTimer('usage')
timer.start()

# Config
wake_check_per = 2
tour_check_per = 40
tour_wait_for_trigger = 2
sleep_wait_for_trigger = 40
# Input Devices
space_nav = "/dev/input/spacenavigator"
quanta_ts = "/dev/input/quanta_touch"
#Time Range Data
time_now = datetime.datetime.now()
#OS variables
sleep_range =  os.environ.get('LG_SLEEP_TIME')
sleep_override = os.environ.get('LG_SLEEP_WAKE')


# Commands
wake_cmd = ">/dev/null /home/lg/bin/lg-run-bg /usr/bin/xset -display :0 dpms force on"
sleep_cmd = ">/dev/null /home/lg/bin/lg-run-bg /usr/bin/xset -display :0 dpms force standby"


##
def configure_range( ranger):
  s_time_raw, e_time_raw = ranger.split('-', -1)
  s_time_hour, s_time_min = s_time_raw.split(':', -1)
  e_time_hour, e_time_min = e_time_raw.split(':', -1)
  s_time = datetime.datetime(time_now.year, time_now.month, time_now.day, int(s_time_hour), int(s_time_min), 00)
  e_time = datetime.datetime(time_now.year, time_now.month, time_now.day+1 , int(e_time_hour), int(e_time_min), 00)
return#

def check_range():
  configure_range(sleep_range)
  if time_now > s_time and time_now < e_time:
    print "within range"
    return True
  else:
    print "outside of range"
    return False

##
def Touched(dev1, dev2, runmode):
  # open file handles first
  with open(dev1) as a, open(dev2) as b:
    for dev in [a, b]:
      fd = dev.fileno()
      fcntl.fcntl(fd, fcntl.F_SETFL, os.O_NONBLOCK)
    # then sleep and let input accumulate
    if   runmode == 1:
      time.sleep(tour_check_per)
    elif runmode == 2:
      time.sleep(wake_check_per)
    # then read input data, if any
    for dev in [a, b]:
      try:
        dev.read(6000)
        return True
      except IOError:
        pass
    # default to return False if no USB devs Touched
    return False

def main():
  if len(sys.argv) != 2:
    print "Usage:", sys.argv[0], "<command>"
    print "<command> will be called every", tour_check_per, "seconds",
    print "after", (tour_check_per * wait_for_trigger), "seconds"
    print "if USB devs are not touched."
    sys.exit(1)

  cmd = sys.argv[1]
  runmode = 1 # 1 = tour, 2 = displaysleep
  cnt = 0
  while True:
    if Touched(space_nav, quanta_ts, runmode):
      cnt = 0
      print "Touched."
      timer.split('active')
      if runmode == 2:
        os.system(wake_cmd)
      runmode = 1
    else:
      cnt += 1
      if cnt >= sleep_wait_for_trigger and check_range() == True:
        runmode = 2
        print sleep_cmd
        os.system(sleep_cmd)
      elif cnt >= tour_wait_for_trigger and check_range() == False:
        print cmd
        timer.split('idle')
        os.system(cmd)
      else:
        print "Wait...", cnt

if __name__ == '__main__':
  main()
