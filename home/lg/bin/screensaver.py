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
import sys, getopt
import time
import datetime
import re
import statsd
from statsd import StatsdTimer



#assign name to self. seen in stats collection.
if os.path.isfile('/etc/debian_chroot'):
  myname = open("/etc/debian_chroot","r").read()
  myname = myname.rstrip('\n')
else:
  myname = os.uname()[1]

statsd.init_statsd({'STATSD_HOST': 'lg-head', 'STATSD_BUCKET_PREFIX': "%s" % myname}
timer = statsd.StatsdTimer('usage')
timer.start()


# Config
## moved to cmd_line_args
wake_check_per = 2
tour_check_per = 40
tour_wait_for_trigger = 2
sleep_wait_for_trigger = 40

# Input Devices
space_nav = "/dev/input/spacenavigator"
quanta_ts = "/dev/input/quanta_touch"
#Time Range Data
time_now = datetime.datetime.now().time()
#OS variables
sleep_range    = os.environ.get('LG_SLEEP_TIME')
sleep_override = os.environ.get('LG_SLEEP_WAKE')
sleep_lock = os.environ.get('LG_SAVERLOCK')
# Commands
wake_cmd = ">/dev/null /home/lg/bin/lg-tv-ctl on"
sleep_cmd = ">/dev/null /home/lg/bin/lg-tv-ctl standby"

#check for hint that device may need to be 'woken'
def sleep_locked( file_name ):
  if os.path.isfile(file_name):
    print "lock_exists:", file_name, "monitor sleep as well as screensaver are disabled!"
    return True
  else:
    print "lock_not_found:", file_name, "monitors will sleep! even when touched!!"
    return False

#configure a logical time range
def configure_range( ranger):
  global s_time, e_time
  s_time_raw, e_time_raw = ranger.split('-', -1)
  s_time_hour, s_time_min = s_time_raw.split(':', -1)
  e_time_hour, e_time_min = e_time_raw.split(':', -1)
  s_time = datetime.datetime(datetime.datetime.now().year, datetime.datetime.now().month, datetime.datetime.now().day, int(s_time_hour), int(s_time_min), 00).time()
  e_time = datetime.datetime(datetime.datetime.now().year, datetime.datetime.now().month, datetime.datetime.now().day , int(e_time_hour), int(e_time_min), 00).time()
  return#

#how to tell if we are in/out of our range.
def check_range():
  configure_range(sleep_range)
  if datetime.datetime.now().time() > s_time and datetime.datetime.now().time() < e_time:
    print "in_range ", "time_now: ", datetime.datetime.now().time() , "sched_start", s_time, "sched_end", e_time
    return True
  else:
    print "out_range", "time_now: ", datetime.datetime.now().time() , "sched_start", s_time, "sched_end", e_time
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
  #use getopts for optparsing
  try:
    opts, args = getopt.getopt(sys.argv[1:],"hp:t:",["--per_value=","--trigger_value="])
  except getopt.GetoptError:
    print 'screensaver.py -p <per_value> -t <trigger_value>'
    sys.exit(2)
  for opt, arg in opts:
    if opt == '-h':
      print 'screensaver.py -p <per_value> -t <trigger_value>'
      sys.exit()
    elif opt in ("-p", "--per_value"):
      wake_check_per = float(arg)
      tour_wait_for_trigger = float(arg)
    elif opt in ("-t", "--trigger_value"):
      tour_check_per = float(arg)
      sleep_wait_for_trigger = float(arg)

  
  cmd = sys.argv[-1] #this should will soon be a parsed argument -e
  runmode = 1 # 1 = tour, 2 = displaysleep
  cnt = 0
  while True:
    if Touched(space_nav, quanta_ts, runmode):
      cnt = 0
      print "Touched.", "schedule:", sleep_range, "run_mode: ", runmode, "count:", cnt
      timer.split('active')
      if runmode == 2:
        os.system(wake_cmd)
      runmode = 1
    else:
      cnt += 1
      if cnt >= sleep_wait_for_trigger and check_range() == True:
        runmode = 2
        print "exec:", sleep_cmd, "schedule:", sleep_range, "run_mode: ", runmode, "count:", cnt
	if sleep_override == "True" and sleep_locked(sleep_lock) == True:
	  #we see there is a wake lock, so we will wake up despite its time to sleep.	
          print "Notice: sleep and screensaver has been placed in override. exec:", wake_cmd 
          timer.split('active')
          os.system(wake_cmd)
	else:
          print "Notice: sleep and screensaver are enabled. exec:", sleep_cmd
	  #good night!
          os.system(sleep_cmd)
	  timer.split('asleep')
      elif cnt >= tour_wait_for_trigger and check_range() == False:
	#good morning!
        print "exec:", wake_cmd, "exec:", cmd, "schedule:", sleep_range, "run_mode: ", runmode, "count:", cnt
        os.system(wake_cmd)
        os.system(cmd)
        timer.split('idle')
      else:
        print "Wait...", "count:", cnt, "run_mode: ", runmode

if __name__ == '__main__':
  main()
