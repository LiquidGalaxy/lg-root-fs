#!/usr/bin/python

import cgi
import cgitb
cgitb.enable()

url = cgi.FieldStorage()

frame = url['frame'].value

with open('/tmp/viewCheck-{0}'.format(frame), 'w') as f:
    f.write('\n')

print 'Content-Type: text/plain\n'
print '{0}'.format(frame)
