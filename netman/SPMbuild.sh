# use netctl or ifupdown-ng

# https://wiki.archlinux.org/title/Netctl
# https://gitlab.archlinux.org/archlinux/netctl
# https://gitlab.archlinux.org/archlinux/netctl/-/tree/master/docs
# https://gitlab.archlinux.org/archlinux/netctl/-/tree/master/docs/examples

# ifupdown
# allow-hotplug
# ethernet devices
# wifi devices
# cell (use ppp, as in netctl)
# PPPoE (use ppp, as in netctl)
# https://manpages.debian.org/bullseye/ifupdown/interfaces.5.en.html
# use ifplugd to "ip link up/down" when an interface is pluged in/out
# 	https://git.busybox.net/busybox/tree/networking/ifplugd.c
# , wifi pre-up: if there is a link and ethernet is unplugged
# , cell pre-up: if ethernet and wifi are unplugged
# making bridges (eg for tethering or creating a router)
# 	https://wiki.debian.org/NetworkConfiguration
# 	https://wiki.alpinelinux.org/wiki/Configure_Networking
# 	https://wiki.alpinelinux.org/wiki/Bridge#Using_pre-up/post-down
# 	https://wiki.alpinelinux.org/wiki/How_to_setup_a_wireless_access_point

# is /etc/hosts required?

# https://wiki.alpinelinux.org/wiki/Wi-Fi
# wpa_supplicant or iwd (without dhcp)
# service
# sudo rule for wifi config program

# finding active net device using iproute2:
# active_net_device="$(ip route show default | head -1 | sed -n 's/.* dev \([^\ ]*\) .*/\1/p')"

# metered_connection() {
# 	local active_net_device="$(ip route show default | head -1 | sed -n "s/.* dev \([^\ ]*\) .*/\1/p")"
# 	local is_metered=false
# 	case "$active_net_device" in
# 		ww*) is_metered=true ;;
# 	esac
# 	# todo: DHCP option 43 ANDROID_METERED
# 	$is_metered
# }

# vpn

# update system timezone when network changes:
# tz set "$offset"
