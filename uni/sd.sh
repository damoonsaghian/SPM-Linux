#!/usr/bin/env sh

# mounting and formatting storage devices

usage_error() {
	echo "usage:"
	echo "	sd mount <dev-name>"
	echo "	sd unmount <dev-name>"
	echo "	sd format backup|fat|exfat <dev-name>"
	exit 1
}

[ "$1" = mount ] && {
	[ -n "$2" ] && usage_error
	
	device_name="$(basename "$2")"
	[ -e /sys/block/"$device_name" ] || {
		echo "there is no storage device named \"$device_name\""
		exit 1
	}
	
	fstype="$(blkid /dev/"$device_name" | sed -rn 's/.*TYPE="(.*)".*/\1/p')"
	if [ "$fstype" = vfat ]; then
		# it seems that vfat does not mount with discard as default (unlike btrfs)
		# if queued trim is supported, use discard option when mounting
		discard_opt=
		if [ "$(cat /sys/block/"$device_name"/queue/discard_granularity)" -gt 0 ] &&
			[ "$(cat /sys/block/"$device_name"/queue/discard_max_bytes)" -gt 2147483648 ]
		then
			discard_opt="discard,"
		fi
		
		if [ -n "$SUDO_UID" ] && [ -n "$SUDO_GID" ]; then
			mount -o ${discard_opt}nosuid,nodev,uid="$SUDO_UID",gid="$SUDO_GID" "$2" /nu/.local/state/mounts/"$device_name"
		else
			mount -o ${discard_opt}nosuid,nodev "$2" /nu/.local/state/mounts/"$device_name"
		fi
	else
		mount -o nosuid,nodev "$2" /nu/.local/state/mounts/"$device_name"
	fi
	exit
}

[ "$1" = unmount ] && {
	[ -n "$2" ] && usage_error
	
	device_name="$(basename "$2")"
	mount_point=/nu/.local/state/mounts/"$device_name"
	[ -d "$mount_point" ] || {
		echo "there is no mounted storage device named \"$device_name\""
		exit 1
	}
	
	# run fstrim for devices supporting unqueued trim
	[ "$(cat /sys/block/"$device_name"/queue/discard_granularity)" -gt 0 ] &&
	[ "$(cat /sys/block/"$device_name"/queue/discard_max_bytes)" -lt 2147483648 ] &&
		fstrim "$mount_point"
	
	umount "$mount_point"
	exit
}

[ "$1" != format ] && [ "$1" != format-inst ] && [ "$1" != format-sys ] && usage_error

target_device="$(basename "$3")"

[ -e /sys/block/"$target_device" ] || {
	echo "there is no storage device named \"$target_device\""
	exit 1
}

# if $target_device is a partition, set it to the parent device
target_device_num="$(cat /sys/class/block/"$target_device"/dev | cut -d ":" -f 1):0"
target_device="$(basename "$(readlink /dev/block/"$target_device_num")")"

# exit if $target_device is the root device
root_partition="$(mount -l | grep " on / " | cut -d ' ' -f 1 | sed -n "s@/dev/@@p")"
root_device_num="$(cat /sys/class/block/"$root_partition"/dev | cut -d ":" -f 1):0"
root_device="$(basename "$(readlink /dev/block/"$root_device_num")")"
if [ "$target_device" = "$root_device" ]; then
	echo "can't install on \"$target_device\"; it contains the running system"
	exit 1
fi

[ "$1" = format ] && [ "$2" = backup ] && {
	mkfs.btrfs -f /dev/"$target_device"
	mount_dir="$(mktemp -d)"
	trap "trap - EXIT; umount '$mount_dir'; rmdir '$mount_dir'" EXIT INT TERM QUIT HUP PIPE
	mount /dev/"$target_device" "$mount_dir"
	chmod 777 "$mount_dir"
	exit
}
[ "$1" = format ] && [ "$2" = fat ] && {
	mkfs.vfat -I -F 32 /dev/"$target_device"
	exit
} 
[ "$1" = format ] && [ "$2" = exfat ] && {
	mkfs.exfat /dev/"$target_device"
	exit
} 
