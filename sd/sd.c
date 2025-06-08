/*
mounting and formatting storage devices

list of devices, notified when changed
https://api-staging.kde.org/solid-index.html
https://gitlab.com/desktop-frameworks/storage

mount with suid bits disabled
mount to ~/.local/state/mounts

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
/*
