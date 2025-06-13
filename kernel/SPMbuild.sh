# https://kernel.org/

# costume modules path: /spm/linux/modules

# custom init path, using kernel parameter: init=/path/to/dinit

# create initramfs containing:
# , the modules and firmwares needed to access the storage device where root resides
# , libc
# , sh, mount, and blkid
# https://docs.kernel.org/admin-guide/initrd.html
# https://gitlab.alpinelinux.org/alpine/mkinitfs
# https://wiki.gentoo.org/wiki/Custom_Initramfs
# https://www.linuxfromscratch.org/blfs/view/svn/postlfs/initramfs.html
# https://git.busybox.net/busybox/plain/docs/mdev.txt
#
# if a CPU microcode is needed, prepend it to initramfs
# https://docs.kernel.org/arch/x86/microcode.html
# https://wiki.archlinux.org/title/Microcode

# wireless-regdb
# https://wireless.wiki.kernel.org/en/developers/regulatory/wireless-regdb

# https://github.com/haiku/haiku
# https://github.com/haiku/haiku/tree/master/src/add-ons/kernel/drivers
