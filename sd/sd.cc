/*
mounting and formatting storage devices

list of devices, notified when changed
https://api-staging.kde.org/solid-index.html
	disable battery and processor
https://gitlab.com/desktop-frameworks/storage

mount with suid bits disabled
mount to ~/.local/state/mounts

mount with read-write access only for processes running with a specific group id
sd mount <group-id>

creating and mounting encrypted directories
https://github.com/netheril96/securefs
https://www.agwa.name/blog/post/easily_running_fuse_in_an_isolated_mount_namespace
sd encrypt <dir-path>
sd decrypt <dir-path>

to access the content of mtp devices:
https://sourceforge.net/p/libmtp
https://sourceforge.net/p/libmtp/code/ci/master/tree/INSTALL (without gcrypt)

to access the content of ios devices:
https://pkgs.alpinelinux.org/package/edge/community/x86_64/libimobiledevice

to access the content of samba devices:
https://archlinux.org/packages/extra/x86_64/smbclient/

exit if it's the system device

format devices
type: fat
mkfs-args: -F, 32, -I (to override partitions)
format non'system devices, format with vfat or exfat (if wants files bigger than 4GB)
for system devices:
sudo sh -c "mkfs.btrfs -f <dev-path>; mount <dev-path> /mnt; chmod 777 /mnt; umount /mnt"
/*
