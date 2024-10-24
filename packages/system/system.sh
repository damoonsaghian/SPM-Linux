#!/apps/env sh
set -e

# bemenu

manage_session() {
	# /usr/local/bin/lock
	# suspend
	# swaymsg exit
	# reboot
	# poweroff
}

#WIFI using nmcli:
#; nmcli dev wifi
#; nmcli --ask dev wifi con <ssid>
#to disconnect from a WIFI network:
#; nmcli con down id <ssid>
manage_wifi() {
	local mode="$(printf "connect\nremove" | fzy)" device= ssid= answer=
	
	if [ "$mode" = connect ]; then
		echo 'select a device:'
		device="$(iwctl device list |
			tail --line=+5 | cut -c 7- | fzy | { read -r first _; echo "$first"; })"
		
		iwctl station "$device" scan
		echo 'select a network to connect:'
		ssid="$(iwctl station "$device" get-networks |
			tail --line=+5 | cut -c 7- | fzy | { read -r first _; echo "$first"; })"
		iwctl station "$device" connect "$ssid"
	fi
	
	if [ "$mode" = remove ]; then
		echo 'select a network to remove:'
		ssid="$(iwctl known-networks list |
			tail --line=+5 | cut -c 7- | fzy | { read -r first _; echo "$first"; })"
		
		echo "remove \"$ssid\"?"
		answer="$(printf "no\nyes" | fzy)"
		[ "$answer" = yes ] || exit
		
		doas iwctl known-networks "$ssid" forget
	fi
}

manage_cell() {
	echo "not yet implemented"
}

# the natural usage domain for Bluetooth is personal devices like headsets
# it perfectly makes sense to pair them per user
manage_bluetooth() {
	local mode= device=
	
	echo "not yet implemented"; exit
	# https://forum.endeavouros.com/t/how-to-script-bluetoothctl-commands/18225/10
	# https://gist.github.com/RamonGilabert/046727b302b4d9fb0055
	# "echo '' | ..." or expect
	#
	# https://git.kernel.org/pub/scm/bluetooth/bluez.git/tree/test/simple-agent
	# https://ukbaz.github.io/howto/python_gio_1.html
	# https://git.kernel.org/pub/scm/bluetooth/bluez.git/tree/doc/device-api.txt
	
	mode="$(printf "add\nremove" | fzy)"
	
	if [ "$mode" = remove ]; then
		bluetoothctl scan on &
		sleep 3
		echo "select a device:"
		device="$(bluetoothctl devices | fzy | { read -r _first mac_address; echo "$mac_address"; })"
		
		if bluetoothctl --agent -- pair "$device"; then
			bluetoothctl trust "$device"
			bluetoothctl connect "$device"
		else
			bluetoothctl untrust "$device"
		fi
	fi
	
	if [ "$mode" = remove ]; then
		echo "select a device:"
		device="$(bluetoothctl devices | fzy | { read -r _first mac_address; echo "$mac_address"; })"
		doas bluetoothctl disconnect "$device"
		doas bluetoothctl untrust "$device"
	fi
}

manage_radio_devices() {
	# wifi, cellular, bluetooth, gps
	local lines= device= action=
	
	lines="$(rfkill -n -o "TYPE,SOFT,HARD")"
	lines="$(printf "all\n%s" "$lines")"
	echo 'select a radio device:'
	device="$(echo "$lines" | fzy | cut -d " " -f1)"

	action="$(printf "block\nunblock" | fzy)"
	doas rfkill "$action" "$device"
}

manage_router() {
	echo "not yet implemented"
	
	# https://wiki.archlinux.org/title/Router
	# https://developers.redhat.com/blog/2018/10/22/introduction-to-linux-interfaces-for-virtual-networking#veth
	
	# ask for add/remove
	# if remove:
	# , show the out devices
	# , ask for the name of devices (or all)
	# , remove the devices from ifupdown-ng config, and from Connman unmanaged
	# if add:
	# , ask for the name of devices to add
	# , put the devices in connman unmanaged
	# , install busybox-extras (for udhcpd)
	# , run a dhcp server on them, using ifupdown-ng (https://github.com/ifupdown-ng/ifupdown-ng/tree/main/doc)
	
	# if the device is a wireless LAN (ie we want a wifi access point)
	# if there is only one wifi device, create a virtual one (concurrent AP-STA mode)
	# https://wiki.archlinux.org/title/software_access_point
	# https://variwiki.com/index.php?title=Wifi_NetworkManager#WiFi_STA.2FAP_concurrency
	# activate AP mode on it, using iwd
	# http://blog.hoxnox.com/gentoo/wifi-hotspot.html
	# https://wiki.alpinelinux.org/wiki/Wireless_AP_with_udhcpd_and_NAT
	# when removing a wireless device, disable AP mode, and delete the virtual device (if any)
	
	#echo -n '[Match]
	#Type=wlan
	#WLANInterfaceType=ap
	#[Network]
	#Address=0.0.0.0/24
	#DHCPServer=yes
	#IPMasquerade=both
	#' > /etc/systemd/network/80-wifi-ap.network
	# https://hackaday.io/project/162164/instructions?page=2
	# https://raspberrypi.stackexchange.com/questions/133403/configure-usb-wi-fi-dongle-as-stand-alone-access-point-with-systemd-networkd
	# https://man.archlinux.org/man/core/systemd/systemd.netdev.5.en
}

# VPN
# https://fedoramagazine.org/systemd-resolved-introduction-to-split-dns/
# https://blogs.gnome.org/mcatanzaro/2020/12/17/understanding-systemd-resolved-split-dns-and-vpn-configuration/

manage_connections() {
	local selected_option="$(printf "wifi\ncellular\nbluetooth\nradio\nrouter" | fzy)"
	case "$selected_option" in
		wifi) manage_wifi ;;
		cellular) manage_cell ;;
		bluetooth) manage_bluetooth ;;
		radio) manage_radio_devices ;;
		router) manage_router ;;
	esac
}

set_timezone() {
	# guess the timezone, but let the user to confirm it
	local geoip_tz= geoip_tz_continent= geoip_tz_city= tz_continent= tz_city=
	geoip_tz="$(wget -q -O- 'http://ip-api.com/line/?fields=timezone')"
	geoip_tz_continent="$(echo "$geoip_tz" | cut -d / -f1)"
	geoip_tz_city="$(echo "$geoip_tz" | cut -d / -f2)"
	tz_continent="$(ls -1 -d /usr/share/zoneinfo/*/ | cut -d / -f5 |
		fzy -p "select a continent: " -q "$geoip_tz_continent")"
	tz_city="$(ls -1 /usr/share/zoneinfo/"$tz_continent"/* | cut -d / -f6 |
		fzy -p "select a city: " -q "$geoip_tz_city")"
	# $HOME/.profile
	# TZ="/spm/installed/system/tzdata/${tz_continent}/${tz_city}"; export TZ
}

change_passwords() {
	local answer="$(printf "user password\nsudo password" | fzy)"
	
	[ "$answer" = "user password" ] && while ! passwd --quiet; do
		echo "an error occured; please try again"
	done
	
	[ "$answer" = "sudo password" ] && while ! sudo passwd --quiet; do
		echo "an error occured; please try again"
	done
}

manage_packages() {
	local mode= package_name= answer=no
	echo 'packages:'
	mode="$(printf "upgrade\nadd\nremove\ninstall SPM Linux" | fzy)"
	
	# if the content of "$spm_dir/status" is "error", turn "packages" and the "update" item under it, red
	
	[ "$mode" = add ] && {
		printf 'search for: '
		read -r search_entry
		ospkg-deb sync
		package_name="$(apt-cache search "$search_entry" | fzy | { read -r first _rest; echo "$first"; })"
		apt-cache show "$package_name"
		echo "install \"$package_name\"?"
		answer="$(printf "yes\nno" | fzy)"
		[ "$answer" = yes ] || exit
	}
	
	[ "$mode" = remove ] && {
		package_name="$(apt-cache search --names-only "^ospkg-$(id -u)--.*" | sed s/^.*--// |
			fzy | { read -r first _rest; echo "$first"; })"
		printf "remove \"$package_name\"?"
		answer="$(printf "no\nyes" | fzy)"
		[ "$answer" = yes ] || exit
	}
	spm "$mode" "$package_name" "$package_name"
	
	[ "$mode" = "install SPM Linux" ] && sh "$(dirname "$0")"/system-install-spmlinux.sh
}

update_boot_firmware() {
	doas fwupdmgr get-devices
	doas fwupdmgr refresh
	doas fwupdmgr get-updates
	doas fwupdmgr update
	
	if [ "$arch" = x86 ] || [ "$arch" = x86_64 ]; then
		limine bios-install "$target_device"
	fi
}

if [ -z "$1" ]; then
	selected_option="$(printf "connections\ntimezone\npasswords\npackages" | fzy)"
else
	selected_option="$1"
fi

case "$selected_option" in
	session) manage_session ;;
	connections) manage_connections ;;
	timezone) set_timezone ;;
	passwords) change_passwords ;;
	packages) manage_packages ;;
esac
