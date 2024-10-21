#!sh

TZ="$script_dir/tzdata/$(cat "$script_dir/timezone")"; export TZ

# run sway (if this script is not called by root or a display manager, and this is the first tty)
if [ ! "$(id -u)" = 0 ] && [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
	exec dbus-run-session sway
else
	exec bash
fi
