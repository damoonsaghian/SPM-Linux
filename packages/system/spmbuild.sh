project_dir="$(dirname "$0")"

# git://busybox.net/busybox/tag/?h=1_36_1
# disable these:
# 	who, last, FEATURE_UTMP
# 	less, man, su, blkid

# btrfs-progs
# blkid libuuid (from util-linux)

# https://git.alpinelinux.org/aports/tree/main/busybox
# https://git.busybox.net/busybox/tree/
# https://www.busybox.net/downloads/BusyBox.html

# https://smarden.org/runit/
# https://man.voidlinux.org/runsvdir.8
# https://git.alpinelinux.org/aports/tree/main/openrc

# init
# PATH=/apps/bb:/apps
# run bb services

# libudev-zero
# https://wiki.alpinelinux.org/wiki/Mdev
# https://github.com/slashbeast/mdev-like-a-boss/blob/master/mdev.conf

# https://docs.voidlinux.org/config/session-management.html
# https://git.sr.ht/~kennylevinsen/seatd
# https://docs.voidlinux.org/config/power-management.html
# https://pkgs.alpinelinux.org/package/edge/main/x86_64/acpid

# login service
# at login run services at /apps/services as the user, supervised

# https://github.com/Duncaen/OpenDoas

# chkpassword.c
# chmod +x

cp $project_dir/sudo.sh $project_dir/.cache/spm/sudo
chmod +x $project_dir/.cache/spm/sudo
# if program is /bin/spm run it without asking for password
# https://unix.stackexchange.com/questions/364/allow-setuid-on-shell-scripts
# https://security.stackexchange.com/questions/194166/why-is-suid-disabled-for-shell-scripts-but-not-for-binaries
# https://www.drdobbs.com/dangers-of-suid-shell-scripts/199101190
# https://github.com/Lancia-Greggori/lanciautils/blob/main/C/priv.c
# https://salsa.debian.org/debian/super/
# "doas" allow password'less: /apps/bash /spm/installed/system/sudo.sh

# console level keybinding: when "F5-8" is pressed: go to console 8

# inhibit suspend/shutdown when an upgrade or a sync is in progress

# define these macros when compiling busybox:
#define _PATH_PASSWD /spm/system/data/passwd
#define _PATH_GROUP /spm/system/data/group
#define _PATH_SHADOW /spm/system/data/shadow
#define _PATH_GSHADOW /spm/system/data/gshadow

# https://github.com/jhawthorn/fzy

default_index="$(printf "$list" | sed -n "/^$default_option$/=" | head -n1)"
[ -z default_index ] && default_index=1
default_index="$((default_index-1))"
selected_option="$(printf "$list" | bemenu -p $prompt -I $default_index)"


ln "$project_dir"/system.sh "$project_dir"/.cache/spm/bin/system
ln "$project_dir"/system-install-spmlinux.sh "$project_dir"/.cache/spm/bin/system-install-spmlinux.sh
chmod +x "$project_dir"/.cache/spm/bin/system

# poweroff when critical battery charge is reached

# https://man.archlinux.org/listing/dbus
# enable dbus service

# ntp sets system time based on UTC which suffers from leap seconds
# "ntpd -w" prints the delay in this format:
# 	"reply from %s: offset:%+f delay:%f status:0x%02x strat:%d refid:0x%08x rootdelay:%f reach:0x%02x"
# add the leap seconds to this delay, and then set the system time
# for this to work properly, system timezone must be set from "right" timezones in tzdata
# https://www.ucolick.org/~sla/leapsecs/right+gps.html
# https://skarnet.org/software/skalibs/flags.html#clockistai
#
# clock synchronisation over WiFi: https://jackhenderson.com.au/projects/time-synchronisation

# when networks changes, get network timezone (cell or local), then set system timezone
# unfortunately it seems that Ofono does not have any dbus api to get network timezone
# 	https://bootlin.com/pub/conferences/2016/meetup/dbus/josserand-dbus-meetup.pdf#page=26
# 	https://git.kernel.org/pub/scm/network/ofono/ofono.git/tree/doc
# 	https://git.kernel.org/pub/scm/network/ofono/ofono.git/tree/src/nettime.c
# https://www.freedesktop.org/software/ModemManager/doc/latest/ModemManager/gdbus-org.freedesktop.ModemManager1.Modem.Time.html
# 	https://lazka.github.io/pgi-docs/ModemManager-1.0/classes/NetworkTimezone.html

# in :.cache/spm/tzdata: directory:
# git clone https://github.com/eggert/tz
# only produce "right" timezones

# iwd
# iwd service

# doas rfkill without password

# ln spmbuild.sh .cache/spm/builds/<arch>/spm.sh
# printf '#!doas sh\nsh $0.sh' > .cache/spm/builds/<arch>/spm
# ln spm-autoupdate.sh .cache/spm/builds/<arch>/data/sv/spm-autoupdate
# chmod +x .cache/spm/builds/<arch>/data/sv/spm-autoupdate
