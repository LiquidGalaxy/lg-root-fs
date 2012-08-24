# PRE-execution setup
echo "linking and/or pre-processing Window Manager config"
if [ $FRAME_NO -eq 0 ]; then
    ln -snf touchscreen-rc.lua ${HOME}/.config/awesome/rc.lua
else
    ln -snf default-rc.lua ${HOME}/.config/awesome/rc.lua
fi
echo "executing LG startup-script"
${HOME}/bin/startup-script.sh | tee logger -p local3.info -i -s 2>>/tmp/err 1>>/tmp/out &
echo "executing window manager"
exec x-window-manager

# vim: set ai et sts=2 sw=2 tw=80 filetype=sh:
