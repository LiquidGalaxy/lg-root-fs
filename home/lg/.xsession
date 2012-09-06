# PRE-execution setup
echo "linking and/or pre-processing Window Manager config"
if [ $FRAME_NO -eq 0 ]; then
    ln -snf touchscreen-rc.lua ${HOME}/.config/awesome/rc.lua
else
    ln -snf default-rc.lua ${HOME}/.config/awesome/rc.lua
fi
echo "executing LG startup-script"
${HOME}/bin/startup-script.sh 3>&1 1>>/tmp/out 2>&3 3>&- | logger -p local3.err -i -s 2>>/tmp/err &
echo "executing window manager"
exec x-window-manager

# vim: set ai et sts=2 sw=2 filetype=sh:
