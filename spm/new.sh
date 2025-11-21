set -e

gnunet_namespace="$(cat "$(dirname "$(realpath "$0")")"/../.meta/gns)"

# if this script is run by any user other than root, just install "spm" to user's home directory, and exit
if [ $(id -u) != 0 ]; then
	state_dir="$XDG_STATE_HOME"
	[ -z "$state_dir" ] && state_dir="$HOME/.local/state"
	
	if [ "$1" = src ]; then
		mkdir -p "$state_dir"/spm
		echo "build'from'src" > "$state_dir"/spm/config
	fi
	
	spm_dir="$state_dir/spm/builds/$gnunet_namespace/spm"
	mkdir -p "$spm_dir"
	cp "$(dirname "$0")/spm.sh" "$spm_dir/"
	sh "$spm_dir"/spm.sh install "$gnunet_namespace" spm
	exit
fi

ARCH="$(uname --machine)"
# list available cpu architectures, and let the user choose
# riscv64, ppc64le, aarch64, x86_64
# current system's cpu architecture is the default (on empty input)
ARCH=
export ARCH

target_device="$1"
if [ -z "$target_device" ]; then
	echo; echo "available storage devices:"
	printf "\tname\tsize\tmodel\n"
	printf "\t----\t----\t-----\n"
	ls -1 --color=never /sys/block/ | sed -n '/^loop/!p' | while read -r device_name; do
		device_size="$(cat /sys/block/"$device_name"/size)"
		device_size="$((device_size / 1000000))GB"
		device_model="$(cat /sys/block/"$device_name"/device/model)"
		printf "\t$device_name\t$device_size\t$device_model\n"
	done
	printf "enter the name of the device to install SPM Linux on: "
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
fi

if ["$(basename "$0")" = spm ]; then
	# this script is run through "spm new" command
	# ask user for mode of installation
	# , intall on internal storage device
	# , install on removable storage device (to install SPM Linux on another system)
	
	if [ "$installation_mode" = removable ]; then
		# if the device does not have one EFI partition of at least 500MB size with fat32 format, create it
		# create  an initramfs that includes programs needed to install SPM Linux, plus the content of this project
		# https://wiki.alpinelinux.org/wiki/How_to_make_a_custom_ISO_image_with_mkimage
		exit
	fi
fi

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

# if the target device has a uefi vfat, and a LUKS encrypted BTRFS partition,
# ask the user whether to to use the current partitions instead of wiping them off
if [ "$target_partition1_is_efi" != true ] ||
	[ "$target_partition1_fstype" != vfat ] ||
	[ "$target_partition2_fstype" != luks ] ||
	{
		echo "it seems that the target device is already partitioned properly"
		printf "do you want to keep the partitions? (Y/n) "
		read -r answer
		[ "$answer" != n ] && while [ "$answer" != n ]; do
			echo "enter the password to open the encrypted root partition"
			cryptsetup open --allow-discards --persistent --type luks  "$target_partition2" "root" || {
				echo "you entered wrong password to decrypt root partition; try again? (Y/n) "
				read -r answer
				[ "$answer" = n ] && break
			}
			root_fstype="$(blkid /dev/mapper/root | sed -rn 's/.*TYPE="(.*)".*/\1/p')"
			[ "$root_fstype" = btrfs ] || {
				echo "can't use the root partition, cause its file system is not BTRFS"
				answer=n
			}
		}
		[ "$answer" = n ]
	}
then
	printf "WARNING! all the data on \"/dev/$target_device\" will be erased; continue? (y/N) "
	read -r answer
	[ "$answer" = y ] || exit
	
	# create partitionsB
	{
	echo g # create a GPT partition table
	echo n # new partition
	echo 1 # make it partition number 1
	echo # default, start at beginning of disk 
	echo +260M # boot parttion
	echo t # change partition type
	echo uefi
	echo n # new partition
	echo 2 # make it partion number 2
	echo # default, start immediately after preceding partition
	echo # default, extend partition to end of disk
	echo w # write the partition table
	echo q # quit
	} | fdisk -w always "/dev/$target_device" > /dev/null
	
	target_partitions="$(echo /sys/block/"$target_device"/"$target_device"* |
		sed -n "s/\/sys\/block\/$target_device\///pg")"
	target_partition1="$(echo "$target_partitions" | cut -d " " -f1)"
	target_partition2="$(echo "$target_partitions" | cut -d " " -f2)"
	
	mkfs.vfat -F 32 "$target_partition1"
	
	luks_key_file="$(mktemp)"
	chmod 600 "$luks_key_file"
	dd if=/dev/random of="$luks_key_file" bs=32 count=1
	cryptsetup luksFormat "$target_partition2" "$luks_key_file"
	# other than a key based slot, create a password based slot
	# warn the user that the passwrod must not be used carelessly
	# only if the system is tampered it will ask for the password
	# use password only if you are sure that the source of tamper is yourself
	cryptsetup luksAddKey "$target_partition2"
	cryptsetup open --allow-discards --persistent --type luks --key-file "$luks_key_file" "$target_partition2" "root"
	
	mkfs.btrfs -f --quiet "/dev/mapper/root"
	
	# https://wiki.archlinux.org/title/Btrfs#Swap_file
fi

# put the boot partition in fstab

cryptroot_uuid= # from $taget_partition2
root_uuid= # from /dev/mapper/root

spm_linux_dir="$(mktemp -d)"
mount /dev/mapper/root "$spm_linux_dir"
trap "trap - EXIT; umount \"$spm_linux_dir\"; rmdir \"$spm_linux_dir\"" EXIT INT TERM QUIT HUP PIPE

mkdir -p "$spm_linux_dir"/{home,tmp,run,proc,sys,dev}
chown 1000:1000 "$spm_linux_dir"/home
chmod a+w "$spm_linux_dir"/tmp

# bootstraping and cross compilation
# https://www.linuxfromscratch.org/lfs/view/stable/
# https://t2sde.org/handbook/html/index.html
# https://buildroot.org/downloads/manual/manual.html
# https://github.com/glasnostlinux/glasnost
# https://github.com/iglunix
# https://github.com/oasislinux/oasis
# https://mcilloni.ovh/2021/02/09/cxx-cross-clang/

if [ "$1" = src ]; then
	mkdir -p "$spm_linux_dir"/var/lib/spm
	echo "build'from'src" > "$spm_linux_dir"/var/lib/spm/config
fi

spm_dir="$spm_linux_dir/var/lib/spm/builds/$gnunet_namespace/spm"
mkdir -p "$spm_dir"
cp "$(dirname "$0")"/spm.sh "$spm_dir"/

export PATH="$spm_linux_dir/usr/bin:$PATH"

echo 'acpid
bluez
chrony
cryptsetup
dbus
dinit
doas
dte
eudev
gnunet
linux
netman
pipewire
sbase
sh
spm
tpm2-tools
util-linux
codev-shell
codev' | while read -r pkg_name; do
	sh "$spm_dir"/spm.sh install "$gnunet_namespace" "$pkg_name"
done

# for headless system whose only interface is network (and obviuosely booted via PXE),
# install ssh (lsh) and skip eudev pipewire bluez codev-shell and codev
# https://wiki.alpinelinux.org/wiki/Installation_on_a_headless_host
# https://wiki.alpinelinux.org/wiki/Netboot_Alpine_Linux_using_iPXE
# https://wiki.alpinelinux.org/wiki/PXE_boot
# https://github.com/macmpi/alpine-linux-headless-bootstrap
# in general provide package groups for different kind of systems

# set sudo password
"$spm_linux_dir"/usr/bin/sudo --passwd --root "$spm_linux_dir"

echo; echo -n "SPM Linux installed successfully; press any key to exit"
read -rsn1
