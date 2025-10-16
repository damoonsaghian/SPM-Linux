#!/usr/bin/env sh

export PATH="/usr/bin"

script_dir="$(dirname "$(realpath "$0")")"

export TZ="$script_dir/tzdata/localtime"
export LANG="en_US.UTF-8"
export MUSL_LOCPATH="$script_dir/locales"
export HOME="/home"
export XDG_RUNTIME_DIR="/run/user/1000"
export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"
export WAYLAND_DISPLAY="wayland-0"

rm -rf /run/user/1000
mkdir -p /run/user/1000
chown 1000:1000 /run/user/1000
chmod 700 /run/user/1000

# run dinit user services, like pipewire, wireplumber, and dbus
# https://manpages.debian.org/trixie/dbus-daemon/dbus-daemon.1.en.html
# setpriv --reuid=1000 --regid=1000 --clear-groups --inh-caps=-all ...

# 1,2 are input,render groups
setpriv --reuid=1000 --regid=1000 --groups=1,2 --inh-caps=-all codev-shell
