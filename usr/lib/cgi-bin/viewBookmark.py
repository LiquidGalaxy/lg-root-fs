#!/usr/bin/python

import cgi

url = cgi.FieldStorage()

tmpbbox  = url['BBOX'].value
bbox     = tmpbbox.split(',')
west     = float(bbox[0])
south    = float(bbox[1])
east     = float(bbox[2])
north    = float(bbox[3])

center_lng = ((east - west) / 2) + west
center_lat = ((north - south) / 2) + south

tmpcamera = url['CAMERA'].value
camera    = tmpcamera.split(',')
camLon    = float(camera[0])
camLat    = float(camera[1])
camAlt    = float(camera[2])
camRange  = float(camera[3])
camTilt   = float(camera[4])
camHead   = float(camera[5])

tmplookat = url['LOOKAT'].value
lookat    = tmplookat.split(',')
lookLon   = float(lookat[0])
lookLat   = float(lookat[1])
lookRange = float(lookat[2])
lookTilt  = float(lookat[3])
lookHead  = float(lookat[4])

plkml = (
   '<?xml version="1.0" encoding="UTF-8"?>\n'
   '<kml xmlns="http://www.opengis.net/kml/2.2">\n'
   '<Placemark>\n'
   '<Style id="no-pushpin"><IconStyle><color>00000000</color></IconStyle><LabelStyle><color>00ffffff</color></LabelStyle></Style>\n'
   '<name>View-centered placemark</name>\n'
   '<styleUrl>#no-pushpin</styleUrl>\n'
   '<Point>\n<coordinates>%.6f,%.6f</coordinates>\n</Point>\n'
   '</Placemark>\n'
   '</kml>'
   ) %(center_lng, center_lat)

camkml = ( 
   'earth@##BookMark##@flytoview=<Camera>'
   '<longitude>%.6f</longitude>'
   '<latitude>%.6f</latitude>'
   '<altitude>%.6f</altitude>'
   '<range>%.6f</range>'
   '<tilt>%.6f</tilt>'
   '<heading>%.6f</heading>'
   '<altitudeMode>absolute</altitudeMode>'
   '</Camera>\n'
   ) %(camLon, camLat, camAlt, camRange, camTilt, camHead)

lookatkml = ( 
   'earth@##BookMark##@flytoview=<LookAt>'
   '<longitude>%.6f</longitude>'
   '<latitude>%.6f</latitude>'
   '<altitude>%.6f</altitude>'
   '<range>%.6f</range>'
   '<tilt>%.6f</tilt>'
   '<heading>%.6f</heading>'
   '<altitudeMode>clampToGround</altitudeMode>'
   '</LookAt>\n'
   ) %(lookLon, lookLat, 0, lookRange, lookTilt, lookHead)

with open('/tmp/cam-bookmark.out', 'w') as f:
    f.write(camkml)

with open('/tmp/lookat-bookmark.out', 'w') as f:
    f.write(lookatkml)

print 'Content-Type: application/vnd.google-earth.kml+xml\n'
print plkml
