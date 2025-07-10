set -e

gnunet_namespace="$(cat "$(dirname "$(realpath "$0")")"/../.meta/gns)"

# if this script is run by any user other than root, just install "spm" to user's home directory, and exit
if [ $(id -u) != 0 ]; then
	if [ "$1" = src ]; then
		state_dir="$XDG_STATE_HOME"
		[ -z "$state_dir" ] && state_dir="$HOME/.local/state"
		mkdir -p "$state_dir"/spm
		echo "build'from'src" > "$state_dir"/spm/config
	fi
	
	gnunet-config --section=ats --option=WAN_QUOTA_IN --value=unlimited
	gnunet-config --section=ats --option=WAN_QUOTA_OUT --value=unlimited
	gnunet-config --section=ats --option=LAN_QUOTA_IN --value=unlimited
	gnunet-config --section=ats --option=LAN_QUOTA_OUT --value=unlimited
	
	spm_dir="$HOME/.local/state/spm/builds/$gnunet_namespace/spm"
	mkdir -p "$spm_dir"
	cp "$(dirname "$0")/spm.sh" "$spm_dir/"
	sh "$spm_dir"/spm.sh install "$gnunet_namespace" spm
	exit
fi

ARCH="$(uname --machine)"
# list available cpu architectures, and let the user choose
# loongarch64, MIPS, Microblaze, PowerPC, powerpc64, x32, RISC-V, OpenRISC, s390x, SuperH
# aarch64    - AArch64 (little endian)
# aarch64_be - AArch64 (big endian)
# arm        - ARM
# arm64      - ARM64 (little endian)
# mips       - MIPS (32-bit big endian)
# mips64     - MIPS (64-bit big endian)
# mips64el   - MIPS (64-bit little endian)
# mipsel     - MIPS (32-bit little endian)
# ppc32      - PowerPC 32
# ppc64      - PowerPC 64
# ppc64le    - PowerPC 64 LE
# riscv32    - 32-bit RISC-V
# riscv64    - 64-bit RISC-V
# systemz    - SystemZ
# wasm32     - WebAssembly 32-bit
# wasm64     - WebAssembly 64-bit
# x86        - 32-bit X86: Pentium-Pro and above
# x86-64     - 64-bit X86: EM64T and AMD64
# current system's cpu architecture is the default (on empty input)
ARCH=
export ARCH

echo; echo "available storage devices:"
printf "\tname\tsize\tmodel\n"
printf "\t----\t----\t-----\n"
ls -1 --color=never /sys/block/ | sed -n '/^loop/!p' | while read -r device_name; do
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
fdisk -l /dev/"$target_device" | sed -n "/$target_partition1.*EFI System/p" | {
	read -r line
	test -n "$line" && target_partition1_is_efi=true
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
	printf "WARNING! all the data on \"/dev/$target_device\" will be erased; continue? (y/N) "
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
	) | fdisk "/dev/$target_device" > /dev/null
	
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

mkdir -p "$spm_linux_dir"/{home,tmp,run,proc,sys,dev}
chown 1000:1000 "$spm_linux_dir"/home
chmod a+w "$spm_linux_dir"/tmp

if [ "$1" = src ]; then
	mkdir -p "$spm_linux_dir"/var/lib/spm
	echo "build'from'src" > "$spm_linux_dir"/var/lib/spm/config
fi

gnunet-config --section=ats --option=WAN_QUOTA_IN --value=unlimited
gnunet-config --section=ats --option=WAN_QUOTA_OUT --value=unlimited
gnunet-config --section=ats --option=LAN_QUOTA_IN --value=unlimited
gnunet-config --section=ats --option=LAN_QUOTA_OUT --value=unlimited

spm_dir="$spm_linux_dir/var/lib/spm/builds/$gnunet_namespace/spm"
mkdir -p "$spm_dir"
cp "$(dirname "$0")"/spm.sh "$spm_dir"/

export PATH="$spm_linux_dir/usr/bin:$PATH"

echo 'acpid
bash
bluez
chrony
dash
dbus
dte
eudev
gnunet
limine
linux
netman
dinit
sbase
sd
spm
sudo
tz
util-linux
swapp
codev' | while read -r pkg_name; do
	sh "$spm_dir"/spm.sh install "$gnunet_namespace" "$pkg_name"
done

echo
"$spm_linux_dir"/usr/bin/sudo passwd
"$spm_linux_dir"/usr/bin/sudo passwd root

echo; echo -n "SPM Linux installed successfully; press any key to exit"
read -rsn1
