# place in /etc/profile.d
[ -z "${RUNNING_UNDER_GDM}" ] && [ -r "${HOME}/etc/shell.conf" ] && . "${HOME}/etc/shell.conf" && export FRAME_NO="$FRAME_NO" LG_FRAMES="$LG_FRAMES"
