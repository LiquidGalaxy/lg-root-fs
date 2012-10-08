#!/usr/bin/env python

import time
import random
import cgi
import cgitb
cgitb.enable()

rid = random.random()
url = cgi.FieldStorage()

if 'place' in url:
  urlplace = url['place'].value
elif 'replace' in url:
  urlplace = url['replace'].value
else:
  urlplace = '0,0,0,0,0,0'

place    = urlplace.split(',')
lon      = float(place[0])
lat      = float(place[1])
alt      = float(place[2])
rng      = float(place[3])
tilt     = float(place[4])
hdg      = float(place[5])
  
#print lon, lat, alt, tilt, hdg

svkml = (
   '<Camera><gx:ViewerOptions><gx:option enabled="0" name="historicalimagery"></gx:option><gx:option enabled="0" name="sunlight"></gx:option><gx:option enabled="1" name="streetview"></gx:option></gx:ViewerOptions>'
   '<longitude>%.6f</longitude>'
   '<latitude>%.6f</latitude>'
   '<altitude>%.6f</altitude>'
   '<range>%.6f</range>'
   '<tilt>%.6f</tilt>'
   '<heading>%.6f</heading>'
   '<altitudeMode>absolute</altitudeMode>'
   '</Camera>\n'
   ) %(lon, lat, alt, rng, tilt, hdg)

print 'Content-type: application/vnd.google-earth.kml+xml'
print

print '<?xml version="1.0" encoding="UTF-8"?>'
print '<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">'
if "place" in url:
  print '<NetworkLink id="sv_force_%d">' % rid
elif "replace" in url:
  print '<Document>'
print '<name>SV Force</name><visibility>1</visibility><open>1</open><flyToView>1</flyToView>'
print svkml
if "place" in url:
  print '<Url><href>http://lg1:81/cgi-bin/sv_force.py?replace={},{},{},{},{},{}</href></Url>'.format(lon,lat,alt,rng,tilt,hdg)
  print '</NetworkLink>'
elif "replace" in url:
  print '</Document>'
print '</kml>'
