set -e

arch="$(uname -m)"

echo "available storage devices:"
lsblk --nodep -o NAME,SIZE,MODEL,MOUNTPOINTS | while read -r line; do echo "    $line"; done

printf "enter the name of the device to install the system on: "
read -r target_device

printf "WARNING! all the data on \"$target_device\" will be erased; continue? (y/N) "
read -r answer
[ "$answer" = y ] || exit

# create partitions
if [ -d /sys/firmware/efi ]; then
	first_part_type=uefi
	first_part_size="512M"
	part_label=gpt
else
	case "$arch" in
	amd64|i386)
		first_part_type="21686148-6449-6E6F-744E-656564454649"
		first_part_size="1M"
		part_label=gpt
		;;
 	ppc64el)
		first_part_type="41,*"
		first_part_size="1M"
		part_label=dos
		;;
	*)
		first_part_type="linux,*"
		first_part_size="512M"
		part_label=dos
		;;
	esac
fi

second_part_type=linux
case "$arch" in
amd64) second_part_type=4f68bce3-e8cd-4db1-96e7-fbcaf984b709 ;;
i386) second_part_type=44479540-f297-41b2-9af7-d131d5f0458a ;;
arm64) second_part_type=b921b045-1df0-41c3-af44-4c6f280d3fae ;;
armel|armhf) second_part_type=69dad710-2ce4-4e3c-b16c-21a1d49abed3 ;;
ppc64el) second_part_type=c31c45e6-3f39-412e-80fb-4809c4980599 ;;
riscv64) second_part_type=72ec70a6-cf74-40e6-bd49-4bda08e8f224 ;;
esac

sfdisk --quiet --wipe always --label $part_label "/dev/$target_device" <<__EOF__
1M,$first_part_size,$first_part_type
,,$second_part_type
__EOF__

target_partitions="$(lsblk --list --noheadings -o PATH "/dev/$target_device")"
target_partition1="$(echo "$target_partitions" | sed -n '2p')"
target_partition2="$(echo "$target_partitions" | sed -n '3p')"

umount --recursive --quiet /mnt || true

# format and mount partitions
mkfs.btrfs -f --quiet "$target_partition2" > /dev/null 2>&1
mount "$target_partition2" /mnt
if [ -d /sys/firmware/efi ]; then
	mkfs.fat -F 32 "$target_partition1" > /dev/null 2>&1
	mkdir -p /mnt/boot/efi
	mount "$target_partition1" /mnt/boot/efi
else
	case "$arch" in
	amd64|i386) ;;
	ppc64el) ;;
	*)
		mkfs.ext2 "$target_partition1" > /dev/null 2>&1
		mkdir /mnt/boot
		mount "$target_partition1" /mnt/boot
		;;
	esac
fi

genfstab -U /mnt > /mnt/etc/fstab

echo 'LANG=C.UTF-8' > /mnt/etc/default/locale

if [ -d /sys/firmware/efi ]; then
	echo "root=UUID=$(findmnt -n -o UUID /) ro quiet" > /etc/kernel/cmdline
	apt-get -qq install systemd-boot
	mkdir -p /boot/efi/loader
	printf 'timeout 0\neditor no\n' > /boot/efi/loader/loader.conf
else
	case "$arch" in
	amd64|i386) apt-get -qq install grub-pc ;;
	ppc64el) apt-get -qq install grub-ieee1275 ;;
	esac
	# lock Grub for security
	# recovery mode in Debian requires root password
	# so there is no need to disable generation of recovery mode menu entries
	# we just have to disable menu editing and other admin operations
	[ -f /boot/grub/grub.cfg ] && {
		printf 'set superusers=""\nset timeout=0\n' > /boot/grub/custom.cfg
		update-grub
	}
fi

# search for required firmwares, and install them
# https://salsa.debian.org/debian/isenkram
# https://salsa.debian.org/installer-team/hw-detect
#
# for now just install all firmwares
apt-get -qq install live-task-non-free-firmware-pc
#
# this script installs required firmwares when a new hardware is added
echo -n '#!/bin/sh
' > /usr/local/bin/install-firmware
chmod +x /usr/local/bin/install-firmware
echo 'SUBSYSTEM=="firmware", ACTION=="add", RUN+="/usr/local/bin/install-firmware %k"' > \
	/etc/udev/rules.d/80-install-firmware.rules

apt-get -qq install pipewire-audio pipewire-v4l2
mkdir -p /etc/wireplumber/main.lua.d
echo 'device_defaults.properties = {
	["default-volume"] = 1.0,
	["default-input-volume"] = 1.0,
}' > /etc/wireplumber/main.lua.d/51-default-volume.lua

echo -n '[Match]
Name=en*
Name=eth*
#Type=ether
#Name=! veth*
[Network]
DHCP=yes
[DHCPv4]
RouteMetric=100
[IPv6AcceptRA]
RouteMetric=100
' > /etc/systemd/network/20-ethernet.network
echo -n '[Match]
Name=wl*
#Type=wlan
#WLANInterfaceType=station
[Network]
DHCP=yes
IgnoreCarrierLoss=3s
[DHCPv4]
RouteMetric=600
[IPv6AcceptRA]
RouteMetric=600
' > /etc/systemd/network/20-wireless.network
echo -n '[Match]
Name=ww*
#Type=wwan
[Network]
DHCP=yes
IgnoreCarrierLoss=3s
[DHCPv4]
RouteMetric=700
[IPv6AcceptRA]
RouteMetric=700
' > /etc/systemd/network/20-wwan.network
# https://gitlab.archlinux.org/archlinux/archiso/-/blob/master/configs/releng/airootfs/etc/systemd/network/20-wwan.network
# https://wiki.archlinux.org/title/Mobile_broadband_modem
# https://github.com/systemd/systemd/issues/20370
systemctl enable systemd-networkd
apt-get -qq install systemd-resolved

apt-get -qq install iwd wireless-regdb bluez rfkill
systemctl enable iwd.service
echo '# allow rfkill for users in the netdev group
KERNEL=="rfkill", MODE="0664", GROUP="netdev"
' > /etc/udev/rules.d/80-rfkill.rules

echo; echo "setting timezone"
# guess the timezone, but let the user to confirm it
command -v wget > /dev/null 2>&1 || apt-get -qq install wget > /dev/null 2>&1 || true
geoip_tz="$(wget -q -O- 'http://ip-api.com/line/?fields=timezone')"
geoip_tz_continent="$(echo "$geoip_tz" | cut -d / -f1)"
geoip_tz_city="$(echo "$geoip_tz" | cut -d / -f2)"
tz_continent="$(ls -1 -d /usr/share/zoneinfo/*/ | cut -d / -f5 |
	fzy -p "select a continent: " -q "$geoip_tz_continent")"
tz_city="$(ls -1 /usr/share/zoneinfo/"$tz_continent"/* | cut -d / -f6 |
	fzy -p "select a city: " -q "$geoip_tz_city")"
ln -sf "/usr/share/zoneinfo/${tz_continent}/${tz_city}" /etc/localtime

echo -n 'polkit.addRule(function(action, subject) {
	if (
		action.id == "org.freedesktop.timedate1.set-timezone" &&
		subject.local && subject.active
	) {
		return polkit.Result.YES;
	}
});
' > /etc/polkit-1/rules.d/49-timezone.rules

cp /mnt/os/spm.sh /bin/spm
chmod +x /bin/spm

# /bin/spm autoupdate
# if AC Power
# after network online
# oneshot service
# TimeoutStopSec=900
# 5min after boot
# every 24h
# 5min randomized delay

. /mnt/os/install-user.sh

cp -r /mnt /var/spm/codev
sh /var/spm/codev/install.sh
ln /var/spm/codev/.cache/spm/0 /usr/local/bin/codev
# store the gnunet url of Codev, so SMP can automatically update it
# echo '' > /var/spm/url-list

echo; echo -n "installation completed successfully"
answer="$(printf "no\nyes" | fzy -p "reboot the system? ")"
[ "$answer" = yes ] && systemctl reboot
