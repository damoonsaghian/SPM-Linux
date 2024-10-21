metered_connection() {
	#nmcli --terse --fields GENERAL.METERED dev show | grep --quiet "yes"
	#dbus: org.freedesktop.NetworkManager Metered
}

metered_connection && exit 0

# if AC Power
# timer
# 5min after boot
# every 24h

# if during autoupdate an error occures:
# ; echo error > $spm_dir/status
