metered_connection() {
	local active_net_device="$(ip route show default | head -1 | sed -n "s/.* dev \([^\ ]*\) .*/\1/p")"
	local is_metered=false
	case "$active_net_device" in
		ww*) is_metered=true ;;
	esac
	# todo: DHCP option 43 ANDROID_METERED
	$is_metered
}

metered_connection && exit 0

# if AC Power
# timer
# 5min after boot
# every 24h
