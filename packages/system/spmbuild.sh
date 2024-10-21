project_dir="$(dirname "$0")"

default_index="$(printf "$list" | sed -n "/^$default_option$/=" | head -n1)"
[ -z default_index ] && default_index=1
default_index="$((default_index-1))"
selected_option="$(printf "$list" | bemenu -p $prompt -I $default_index)"

ln "$project_dir"/system.sh "$project_dir"/.cache/spm/bin/system
ln "$project_dir"/system-install-spmlinux.sh "$project_dir"/.cache/spm/bin/system-install-spmlinux.sh
chmod +x "$project_dir"/.cache/spm/bin/system

# create exch executable, which will be used by spm.sh to do atomic update for installed packages
# https://github.com/util-linux/util-linux/blob/master/misc-utils/exch.c

# ln spmbuild.sh .cache/spm/builds/<arch>/spm.sh
# printf '#!doas sh\nsh $0.sh' > .cache/spm/builds/<arch>/spm
# ln spm-autoupdate.sh .cache/spm/builds/<arch>/data/sv/spm-autoupdate
# chmod +x .cache/spm/builds/<arch>/data/sv/spm-autoupdate

# if [ $(id -u) != 0 ]; then
# 	echo '\n#runit on ~/.local/sv\n' >> "$HOME/.bash_profile"
# fi

# inhibit suspend/shutdown when an upgrade is in progress

# poweroff when critical battery charge is reached

# iwd
# iwd service
# doas rule

# modemmanager without polkit
# https://gitlab.freedesktop.org/mobile-broadband/ModemManager/-/blob/main/data/org.freedesktop.ModemManager1.conf.polkit
# https://gitlab.freedesktop.org/mobile-broadband/ModemManager/-/blob/main/data/org.freedesktop.ModemManager1.policy.in.in
# https://gitlab.alpinelinux.org/alpine/aports/-/blob/master/community/modemmanager/modemmanager.rules
# https://modemmanager.org/docs/
# modemmanager service

echo '#!/bin/sh
# update system timezone
' > /etc/NetworkManager/dispatcher.d/09-dispatch-script
chmod 755 /etc/NetworkManager/dispatcher.d/09-dispatch-script

# https://www.freedesktop.org/software/ModemManager/doc/latest/ModemManager/gdbus-org.freedesktop.ModemManager1.Modem.Time.html
# https://lazka.github.io/pgi-docs/ModemManager-1.0/classes/NetworkTimezone.html
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
echo "$tz" > $script_dir/var/config/timezone

# in :.cache/spm/tzdata: directory:
# git clone https://github.com/eggert/tz
# only produce "right" timezones
