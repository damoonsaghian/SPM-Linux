set -e

arch="$(uname -m)"
carch="$1"

echo "available storage devices:"
fdisk -l | while read -r line; do
	printf "\t$line"
	# /sys/blocks ignore loop*
	# /sys/block/$device_name/device/model
	# /sys/block/$device_name/size
done

printf "enter the name of the device to install the system on: "
read -r target_device

# exit if it's the system device

# if the disk has a uefi vfat plus a btrfs partition,
# and the at the root of the btrfs partitions, "apps" and "spm" directories exist,
# ask the user to use the current partitions instead of wiping the disk

printf "WARNING! all the data on \"$target_device\" will be erased; continue? (y/N) "
read -r answer
[ "$answer" = y ] || exit

# https://wiki.artixlinux.org/Main/Installation
# https://gitea.artixlinux.org/artix
# https://packages.artixlinux.org/
#
# https://docs.alpinelinux.org/user-handbook/0.1a/Installing/setup_alpine.html
# https://gitlab.alpinelinux.org/alpine
# https://gitlab.alpinelinux.org/alpine/alpine-conf
# https://pkgs.alpinelinux.org/package/edge/main/x86_64/alpine-base
#
# https://kisslinux.org/ https://github.com/kisslinux/
# https://www.linuxfromscratch.org/ https://www.linuxfromscratch.org/lfs/view/stable/
# https://github.com/gobolinux
# https://sta.li/
# https://t2sde.org/handbook/html/index.html
# https://buildroot.org/downloads/manual/manual.html

# https://github.com/limine-bootloader/limine
# https://github.com/limine-bootloader/limine/blob/v8.x/USAGE.md
# https://github.com/limine-bootloader/limine/blob/v8.x/CONFIG.md
# create vfat ESP partition
# if arch is x86 or x86_64, install BIOS support too
# if arch is ppc64el, create "syslinux.cfg" (only OPAL Petitboot based systems are supported)

# fdisk script
# https://askubuntu.com/questions/741679/automated-shell-script-to-run-fdisk-command-with-user-input
# https://stackoverflow.com/questions/35166147/bash-script-with-fdisk
# https://superuser.com/questions/332252/how-to-create-and-format-a-partition-using-a-bash-script
# https://wiki.archlinux.org/title/Fdisk

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

# create partitions
# format the main partition with BTRFS
# create a directory in /tmp and mount the root
# create these directories:
# apps spm dev proc sys tmp
# copy builtin packages to $mount_dir/spm/packages
# add $mount_dir/apps/bb and $mount_dir/apps to the begining of $PATH

# bootstrap
# mount /apps and /spm
# install gcc busybox linux git gnunet fsprogs sway

# grep "^$device_path " /proc/mounts | cut -d ' ' -f 2

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

mkdir -p /run/mount/spm-linux/spm/installed/system
cp "$project_dir"/packages/system/spm.sh /run/mount/spm-linux/spm/installed/system/spm.sh

ls -1 "$project_dir"/packages/ | while read -r pkg_name; do
	url="gnunet://$my_name_space/packages/spm-linux/packages/$pkg_name"
	sh /run/mount/spm-linux/spm/installed/system/spm.sh "$url"
done

sh /run/mount/spm-linux/spm/installed/system/spm.sh "gnunet://$my_name_space/packages/codev"

echo; echo -n "set username: "
read -r username
groupadd -f netdev; groupadd -f bluetooth
useradd --create-home --groups "$username",netdev,bluetooth,sudo --shell /bin/bash "$username" || true
cat <<'__EOF__' >> "/home/$username/.bashrc"
export PS1="\e[7m \u@\h \e[0m \e[7m \w \e[0m\n> "
shopt -q login_shell &&
	printf '\nenter "system" to configure system settings\n'
__EOF__

while ! passwd --quiet "$username"; do
	echo "an error occured; please try again"
done
echo; echo "set sudo password"
while ! passwd --quiet; do
	echo "an error occured; please try again"
done
# lock root account
passwd --lock root

echo; echo "setting timezone"
# guess the timezone, but let the user to confirm it
geoip_tz="$(wget -q -O- 'http://ip-api.com/line/?fields=timezone')"
geoip_tz_continent="$(echo "$geoip_tz" | cut -d / -f1)"
geoip_tz_city="$(echo "$geoip_tz" | cut -d / -f2)"
tz_continent="$(ls -1 -d /usr/share/zoneinfo/*/ | cut -d / -f5 |
	fzy -p "select a continent: " -q "$geoip_tz_continent")"
tz_city="$(ls -1 /usr/share/zoneinfo/"$tz_continent"/* | cut -d / -f6 |
	fzy -p "select a city: " -q "$geoip_tz_city")"
# $HOME/.profile
# TZ="/spm/installed/system/tzdata/${tz_continent}/${tz_city}"; export TZ

echo; echo -n "installation completed successfully"
printf "reboot the system? (Y/n)"
read -r answer
[ "$answer" = n ] || reboot
