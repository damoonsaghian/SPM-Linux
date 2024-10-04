project_dir="$(dirname "$0")"

# https://git.alpinelinux.org/aports/tree/main/busybox
# https://git.busybox.net/busybox/tree/
# https://www.busybox.net/downloads/BusyBox.html
# git://busybox.net/busybox/tag/?h=1_36_1
# disable these:
# 	who, last, FEATURE_UTMP, wget, diff and cmp
# 	less, man, su, blkid

# btrfs-progs
# blkid libuuid (from util-linux)

# create exch executable, which will be used by spm.sh to do atomic update for installed packages
# https://github.com/util-linux/util-linux/blob/master/misc-utils/exch.c

# https://smarden.org/runit/
# https://man.voidlinux.org/runsvdir.8
# https://git.alpinelinux.org/aports/tree/main/openrc
#
# init
# PATH=/apps/bb:/apps
# run bb services
# mount a tmpfs in /run and /tmp

# libudev-zero
# https://wiki.alpinelinux.org/wiki/Mdev
# https://github.com/slashbeast/mdev-like-a-boss/blob/master/mdev.conf

# https://docs.voidlinux.org/
#
# https://wiki.artixlinux.org/Main/Installation
# https://gitea.artixlinux.org/artix
# https://packages.artixlinux.org/
#
# https://docs.alpinelinux.org/user-handbook/0.1a/Installing/setup_alpine.html
# https://gitlab.alpinelinux.org/alpine
# https://gitlab.alpinelinux.org/alpine/alpine-conf
# https://pkgs.alpinelinux.org/package/edge/main/x86_64/alpine-base
#
# https://github.com/glasnostlinux/glasnost
# https://www.linuxfromscratch.org/ https://www.linuxfromscratch.org/lfs/view/stable/
# https://github.com/iglunix
# https://github.com/gobolinux
# https://github.com/oasislinux/oasis
# https://sta.li/
# https://t2sde.org/handbook/html/index.html
# https://buildroot.org/downloads/manual/manual.html

tz="$(echo "$TZ")"
[ -z "$tz" ] && [ -L /etc/localtime ] && tz="$(realpath /etc/localtime)"
# if $tz starts with slash or dot, cut */zoneinfo/ prefix
[ -z "$tz" ] || {
	echo; echo "setting timezone"
	# guess the timezone, but ask the user to confirm it
	geoip_tz="$(wget -q -O- 'http://ip-api.com/line/?fields=timezone')"
	geoip_tz_continent="$(echo "$geoip_tz" | cut -d / -f1)"
	geoip_tz_city="$(echo "$geoip_tz" | cut -d / -f2)"
	tz_continent="$(ls -1 -d /usr/share/zoneinfo/*/ | cut -d / -f5 |
		fzy -p "select a continent: " -q "$geoip_tz_continent")"
	tz_city="$(ls -1 /usr/share/zoneinfo/"$tz_continent"/* | cut -d / -f6 |
		fzy -p "select a city: " -q "$geoip_tz_city")"
	tz="${tz_continent}/${tz_city}"
}
# if it's different:
echo "$tz" > $script_dir/timezone

# login service
# at login:
# , mkdir -p /run/user/$user_id
# , chmod 700 /run/user/$user_id
# , export XDG_RUNTIME_DIR=/run/user/$user_id
# , run services at /apps/sv as the user, supervised
# copy "loginit.sh" to "login" in the build dir, under sv dir

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
# doas rule

# doas rfkill without password

# ln spmbuild.sh .cache/spm/builds/<arch>/spm.sh
# printf '#!doas sh\nsh $0.sh' > .cache/spm/builds/<arch>/spm
# ln spm-autoupdate.sh .cache/spm/builds/<arch>/data/sv/spm-autoupdate
# chmod +x .cache/spm/builds/<arch>/data/sv/spm-autoupdate
