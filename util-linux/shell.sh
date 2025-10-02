#!/usr/bin/env sh

script_dir="$(dirname "$(realpath "$0")")"

export XDG_RUNTIME_DIR="/run/user/$(id -u)"

cd /home

export TZ="$script_dir/tzdata/localtime"
export HOME="/home"
export PATH="$PATH:/$HOME/.local/bin"

# run services at /home/.spm/exp/sv, as the user 1000 (using setpriv)
# including dbus session bus: https://manpages.debian.org/trixie/dbus-daemon/dbus-daemon.1.en.html

clsh() {
	# ask user for lockscreen password and check it:
	doas -u 1000 true && bash --norc
	# to prevent BadUSB, lock when a new input device is connected
}

if [ "$(tty)" = "/dev/tty1" ]; then
	codev-shell || clsh
else
	clsh
fi

# stop-services
