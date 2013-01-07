#!/usr/bin/env python

import os
import inspect
import time
import random
import cgi
import cgitb
cgitb.enable()

FILE_NAME = os.path.basename(inspect.getfile(inspect.currentframe()))

rid = random.random()
url = cgi.FieldStorage()

rem_add = cgi.escape(os.environ["REMOTE_ADDR"])

if 'place' in url:
  urlplace = url['place'].value
elif 'replace' in url:
  urlplace = url['replace'].value
else:
  urlplace = '0,0,0,0,0,0,0'

place    = urlplace.split(',')
lon      = float(place[0])
lat      = float(place[1])
alt      = float(place[2])
rng      = float(place[3])
tilt     = float(place[4])
hdg      = float(place[5])
teralt   = float(place[6])
  
altRelGrnd = alt - teralt

sv_kml = (
   '<Camera>\n<gx:ViewerOptions>\n<gx:option enabled="0" name="historicalimagery"></gx:option>\n<gx:option enabled="0" name="sunlight"></gx:option>\n<gx:option enabled="1" name="streetview"></gx:option>\n</gx:ViewerOptions>\n'
   '<longitude>%.6f</longitude>\n'
   '<latitude>%.6f</latitude>\n'
   '<altitude>%.6f</altitude>\n'
   '<range>%.6f</range>\n'
   '<tilt>%.6f</tilt>\n'
   '<heading>%.6f</heading>\n'
   '<altitudeMode>absolute</altitudeMode>\n'
   '</Camera>\n'
   ) %(lon, lat, alt, rng, tilt, hdg)

kml_doc = (
   'Content-type: application/vnd.google-earth.kml+xml\n\n'
   '<?xml version="1.0" encoding="UTF-8"?>\n'
   '<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">\n'
   )
if "place" in url:
  kml_doc += '<NetworkLink id="sv_force_%f">\n' % rid
elif "replace" in url:
  kml_doc += '<Document>\n'

# grab info from state file
try:
  with open('/tmp/sv_force-' + rem_add + '.state', 'r+') as state_f:
    same_graticule = 'false'
    state = state_f.read()
    state_arr = state.split('x')
    responseCount = int(state_arr[2])

    if state_arr[0] == '%d' % lon and state_arr[1] == '%d' % lat:
        same_graticule = 'true'

    if altRelGrnd >= 60.00:
        responseCount = 0

    if "place" in url and altRelGrnd <= 60.00 and responseCount <= 9:
      kml_doc += '<name>SV Force</name>\n<visibility>1</visibility>\n<open>1</open>\n<flyToView>1</flyToView>\n'
    else:
      kml_doc += '<name>SV Force</name>\n<visibility>1</visibility>\n<open>1</open>\n<flyToView>0</flyToView>\n'

    if same_graticule == 'true':
      responseCount += 1

    curGratiCount = '%dx%dx%d' %(lon, lat, responseCount)
    # output state information into different tmp file for each remote IP
    if "place" in url:
      state_f.seek(0)
      state_f.write(str(curGratiCount))
      state_f.truncate()

except IOError as e:
  with open('/tmp/sv_force-' + rem_add + '.state', 'w+') as state_f:
    curGratiCount = '%dx%dx%d' %(lon, lat, 1)
    # output state information into different tmp file for each remote IP
    if "place" in url:
      state_f.write(str(curGratiCount))

kml_doc += sv_kml

if "place" in url:
  kml_doc += '<Url><href>{}?replace={},{},{},{},{},{},{}</href></Url>'.format(FILE_NAME,lon,lat,alt,rng,tilt,hdg,teralt)
  kml_doc += '</NetworkLink>\n'
elif "replace" in url:
  kml_doc += '</Document>\n'

kml_doc += '</kml>'
print kml_doc
