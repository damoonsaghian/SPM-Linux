#!/usr/bin/env sh

export PATH="/usr/bin"

script_dir="$(dirname "$(realpath "$0")")"

export TZ="$script_dir/tzdata/localtime"
export LANG="en_US.UTF-8"
export MUSL_LOCPATH="$script_dir/locales"
export XDG_RUNTIME_DIR="/run/user/1000"

rm -rf /run/user/1000
mkdir -p /run/user/1000
chown 1000:1000 /run/user/1000
chmod 700 /run/user/1000

# run services at /home/.spm/exp/sv
# including dbus session bus: https://manpages.debian.org/trixie/dbus-daemon/dbus-daemon.1.en.html

if [ "$(tty)" = "/dev/tty1" ]; then
	# 1,2 are input,video groups
	setpriv --reuid=999 --regid=999 --groups=1,2 --inh-caps=-all codev-shell ||
	setpriv --reuid=999 --regid=999 --clear-groups --inh-caps=-all codev-shell text
else
	setpriv --reuid=999 --regid=999 --clear-groups --inh-caps=-all codev-shell text
fi
