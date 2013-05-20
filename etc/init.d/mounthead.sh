#!/bin/sh
### BEGIN INIT INFO
# Provides:          mounthead
# Required-Start:    
# Required-Stop:     
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Mount NFS volumes
# Description:       Mount head node NFS volumes.
### END INIT INFO

# this fixes mount failures before lg-head can be resolved.

mount /media
