set -e

if [ "$1" = build ]; then
	build_from_src=true
	arch="$2"
else
	arch="$1"
fi
[ -z "$arch" ] && arch="$(uname --machine)"

gnunet_namespace=

echo; echo "available storage devices:"
printf "\tname\tsize\tmodel\n"
printf "\t----\t----\t-----\n"
ls -1 --color=never /sys/block/ | grep -v "^loop" | while read -r device_name; do
	device_size="$(cat /sys/block/"$device_name"/size)"
	device_size="$((device_size / 1000000))GB"
	device_model="$(cat /sys/block/"$device_name"/device/model)"
	printf "\t$device_name\t$device_size\t$device_model\n"
done
printf "enter the name of the device to install SPM Linux on it: "
read -r target_device
test -e /sys/block/"$target_device" || {
	echo "there is no storage device named \"$target_device\""
	exit 1
}

root_partition="$(df / | tail -n 1 | cut -d " " -f 1 | cut -d / -f 3)"
root_device_num="$(cat /sys/class/block/"$root_partition"/dev | cut -d ":" -f 1):0"
root_device="$(basename "$(readlink /dev/block/"$root_device_num")")"
if [ "$target_device" = "$root_device" ]; then
	echo "can't install on \"$target_device\", since it contains the running system"
	exit 1
fi

# if the target device has a uefi vfat, plus a btrfs partition,
# ask the user to use the current partitions instead of wiping them off
target_partitions="$(echo /sys/block/"$target_device"/"$target_device"* |
	sed -n "s/\/sys\/block\/$target_device\///pg")"
target_partition1="$(echo "$target_partitions" | cut -d " " -f1)"
target_partition2="$(echo "$target_partitions" | cut -d " " -f2)"
fdisk -l /dev/"$target_device" | grep "$target_partition1" | {
	grep "EFI System" &> /dev/null &&
	target_partition1_is_efi=true
}
target_partition1_fstype="$(blkid /dev/"$target_partition1" | sed -rn 's/.*TYPE="(.*)".*/\1/p')"
target_partition2_fstype="$(blkid /dev/"$target_partition2" | sed -rn 's/.*TYPE="(.*)".*/\1/p')"
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
	) | fdisk "$target_device"
	
	target_partitions="$(echo /sys/block/"$target_device"/"$target_device"* |
		sed -n "s/\/sys\/block\/$target_device\///pg")"
	target_partition1="$(echo "$target_partitions" | cut -d " " -f1)"
	target_partition2="$(echo "$target_partitions" | cut -d " " -f2)"
	
	# format the partitions
	mkfs.vfat -F 32 "$target_partition1"
	mkfs.btrfs -f --quiet "$target_partition2"
fi

spm_linux_dir="$(mktemp -d)"
mount "$target_partition2" "$spm_linux_dir"
trap "trap - EXIT; umount \"$spm_linux_dir\"; rmdir \"$spm_linux_dir\"" EXIT INT TERM QUIT HUP PIPE

mkdir -p "$spm_linux_dir"/{apps,packages,etc,var/{cache,lib,log,tmp},tmp,run,proc,sys,dev,boot}

mkdir -p "$spm_linux_dir"/packages/installed/"$gnunet_namespace"/spm
cp "$(dirname "$0")"/spm.sh "$spm_linux_dir"/packages/installed/"$gnunet_namespace"/spm/
if [ "$build_from_src" = true ]; then
	echo "use_prebuilt = true" > "$spm_linux_dir"/etc/spm/config
fi

gnunet-config --section=ats --option=WAN_QUOTA_IN --value=unlimited
gnunet-config --section=ats --option=WAN_QUOTA_OUT --value=unlimited
gnunet-config --section=ats --option=LAN_QUOTA_IN --value=unlimited
gnunet-config --section=ats --option=LAN_QUOTA_OUT --value=unlimited

echo 'acpid
bash
bluez
busybox
chrony
dbus
eudev
fwupd
limine
linux
netman
sd
seatd
spm
sudo
swapps
sway
termulator
tz
codev' | while read -r pkg_name; do
	url="gnunet://$gnunet_namespace/packages/$pkg_name"
	sh "$spm_linux_dir"/packages/installed/spm/spm.sh install "$pkg_name" "$url"
done

if [ "$arch" = x86 ] || [ "$arch" = x86_64 ]; then
	limine bios-install "$target_device"
elif [ "$arch" = ppc64le ]; then
	# only OPAL Petitboot based systems are supported
	mount "$target_partition1" "$spm_linux_dir"/boot
	cat <<-__EOF__ > "$spm_linux_dir"/boot/syslinux.cfg
	PROMPT 0
	LABEL SPM Linux
		LINUX vmlinuz
		APPEND root=UUID=$(blkid /dev/"$target_partition2" | sed -rn 's/.*UUID="(.*)".*/\1/p') rw
		INITRD initramfs.img
	__EOF__
	umount "$spm_linux_dir"/boot
fi

echo; printf "set username: "
read -r username
while ! "$spm_linux_dir"/apps/adduser --shell /bin/bash "$username"; do
	read -r username
done
"$spm_linux_dir"/apps/addgroup --system sudo
"$spm_linux_dir"/apps/addgroup "$username" sudo
while ! "$spm_linux_dir"/apps/passwd "$username"; do
	true
done
while ! "$spm_linux_dir"/apps/passwd; do
	true
done
# lock root account
"$spm_linux_dir"/apps/passwd --lock root

echo; echo -n "SPM Linux installed successfully; press any key to exit"
read -rsn1
