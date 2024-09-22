set -e

arch="$1"

echo "available storage devices:"
ls -1 --color=never /sys/block | grep -v "^loop" | while read -r device_name; do
	device_size="$(cat /sys/block/"$device_name"/size)"
	device_size="$((device_size / 1000000))GB"
	device_model="$(cat /sys/block/"$device_name"/device/model)"
	printf "\t$device_name\t$device_size\t$device_model\n"
done

printf "enter the name of the device (the first word) to install the system on: "
read -r target_device

root_partition="$(df / | tail -1 | cut -d " " -f 1 | cut -d / -f 3)"
root_device_num="$(cat /sys/class/block/"$root_partition"/dev | cut -d ":" -f 1):0"
root_device="$(basename "$(readlink /dev/block/"$root_device_num")")"
if [ "$target_device" = "$root_device" ]; then
	echo "can't install on \"$target_device\", since it contains the running system"
	exit 1
fi

# if the target device has a uefi vfat, plus a btrfs partition,
# ask the user to use the current partitions instead of wiping them off
target_partitions="$(echo /sys/block/"$target_device"/"$target_device"* |
	sed -n "s/\/sys\/block\/$target_device\///p" )"
target_partition1="$(echo "$target_partitions" | cut -d " " -f1 )"
target_partition2="$(echo "$target_partitions" | cut -d " " -f2 )"
fdisk -l /dev/"$target_device" | grep "$target_partition1" | {
	grep "EFI System" &> /dev/null &&
	target_partition1_is_efi=true
}
target_partition1_fstype="$(blkid /dev/"$target_partition1" | sed -rn 's/.*TYPE="(.*)".*/\1/p' )"
target_partition2_fstype="$(blkid /dev/"$target_partition2" | sed -rn 's/.*TYPE="(.*)".*/\1/p' )"
if [ "$target_partition1_is_efi" != true ] ||
	[ "$target_partition1_fstype" != vfat ] ||
	[ "$target_partition2_fstype" != btrfs ] || {
		echo "it seems that the target device is already partitioned properly"
		printf "do you want to keep them? (Y/n) "
		read -r answer
		[ "$answer" = n ]
	}
then
	printf "WARNING! all the data on \"$target_device\" will be erased; continue? (y/N) "
	read -r answer
	[ "$answer" = y ] || exit
	
	# create partitions
	(
	echo g # create a GPT partition table
	echo n # new partition
	echo 1 # make it partition number 1
    echo # default, start at beginning of disk 
	echo +512M # 512 MB boot parttion
	echo t # change partition type
	echo EFI System
	echo n # new partition
	echo 2 # make it partion number 2
	echo # default, start immediately after preceding partition
	echo # default, extend partition to end of disk
	echo w # write the partition table
	echo q # quit
	) | fdisk $target_device
	
	# format the partitions
	mkfs.fat -F 32 "$target_partition1" > /dev/null 2>&1
	mkfs.btrfs -f --quiet "$target_partition2" > /dev/null 2>&1
fi

mount "$target_partition2" /mnt

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

# create a directory in /tmp and mount the root
# create these directories:
# apps spm dev proc sys tmp
# copy builtin packages to $mount_dir/spm/packages
# add $mount_dir/apps/bb and $mount_dir/apps to the begining of $PATH

# bootstrap
# mount /apps and /spm
# install gcc busybox linux git gnunet fsprogs sway

# https://github.com/limine-bootloader/limine
# https://github.com/limine-bootloader/limine/blob/v8.x/USAGE.md
# https://github.com/limine-bootloader/limine/blob/v8.x/CONFIG.md
if [ "$arch" = x86 ] || [ "$arch" = x86_64 ]; then
	# install BIOS support
elif [ "$arch" = ppc64le ]; then
	# create "syslinux.cfg" (only OPAL Petitboot based systems are supported)
fi

mkdir -p /run/mount/spm-linux/spm/installed/system
cp "$project_dir"/packages/system/spm.sh /run/mount/spm-linux/spm/installed/system/spm.sh
if [ "$2" = "from-src" ]; then
	echo "use_prebuilt = true" > /run/mount/spm-linux/spm/config
fi

mkdir -p /run/mount/spm-linux/spm/downloads
cp -r "$project_dir"/packages /run/mount/spm-linux/spm/downloads/"$my_name_space"

ls -1 "$project_dir"/packages/ | while read -r pkg_name; do
	url="gnunet://$my_name_space/packages/spm-linux/packages/$pkg_name"
	sh /run/mount/spm-linux/spm/installed/system/spm.sh install "$pkg_name" "$url"
done

sh /run/mount/spm-linux/spm/installed/system/spm.sh install "gnunet://$my_name_space/packages/codev"

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
