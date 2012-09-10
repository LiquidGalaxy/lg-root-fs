# PRE-execution setup
#

# LG startup
echo "executing LG startup-script"
${HOME}/bin/startup-script.sh 3>&1 1>>/tmp/out 2>&3 3>&- | logger -p local3.err -i -s 2>>/tmp/err &

# window manager
echo "executing window manager"
exec x-window-manager

# vim: set ai et sts=2 sw=2 filetype=sh:
