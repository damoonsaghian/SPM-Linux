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

# https://docs.voidlinux.org/config/session-management.html
# https://git.sr.ht/~kennylevinsen/seatd
# https://docs.voidlinux.org/config/power-management.html
# https://pkgs.alpinelinux.org/package/edge/main/x86_64/acpid

# login service
# at login run services at /apps/services as the user, supervised

# https://github.com/Duncaen/OpenDoas

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
ln "$project_dir"/system-mkportable.sh "$project_dir"/.cache/spm/bin/system-mkportabel.sh
chmod +x "$project_dir"/.cache/spm/bin/system

# poweroff when critical battery charge is reached

# https://man.archlinux.org/listing/dbus
# https://github.com/bus1/dbus-broker?tab=readme-ov-file
# https://github.com/bus1/dbus-broker/wiki
# https://github.com/bus1/dbus-broker/wiki/Deviations
# https://man.archlinux.org/man/core/dbus-broker/dbus-broker.1.en
# https://man.archlinux.org/man/core/dbus-broker/dbus-broker-launch.1.en

# ntp sets system time based on UTC which suffers from leap seconds
# "ntpd -w" prints the delay in this format:
# 	"reply from %s: offset:%+f delay:%f status:0x%02x strat:%d refid:0x%08x rootdelay:%f reach:0x%02x"
# add the leap seconds to this delay, and then set the system time
# for this to work properly, system timezone must be set from "right" timezones in tzdata
# https://www.ucolick.org/~sla/leapsecs/right+gps.html
# https://skarnet.org/software/skalibs/flags.html#clockistai
#
# clock synchronisation over Wi-Fi: https://jackhenderson.com.au/projects/time-synchronisation

# when networks changes, get network timezone (cell or local), then set system timezone
# unfortunately it seems that Ofono does not have any dbus api to get network timezone
# 	https://bootlin.com/pub/conferences/2016/meetup/dbus/josserand-dbus-meetup.pdf#page=26
# 	https://git.kernel.org/pub/scm/network/ofono/ofono.git/tree/doc
# 	https://git.kernel.org/pub/scm/network/ofono/ofono.git/tree/src/nettime.c
# https://www.freedesktop.org/software/ModemManager/doc/latest/ModemManager/gdbus-org.freedesktop.ModemManager1.Modem.Time.html
# 	https://lazka.github.io/pgi-docs/ModemManager-1.0/classes/NetworkTimezone.html

# tzdata
# during login: TZ=/spm/system/tzdata/.../...

# ln spmbuild.sh .cache/spm/builds/<arch>/spm.sh
# printf '#!doas sh\nsh $0.sh' > .cache/spm/builds/<arch>/spm
