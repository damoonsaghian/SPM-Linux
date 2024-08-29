# https://kernel.org/

# costume modules path: /spm/linux/modules

# custom init path, using kernel parameter: init=/spm/busybox/init

# create initramfs containing:
# , the modules and firmwares needed to access the storage device where root resides
# , libc
# , busybox executable and two symlinks to it named "mount" and "mdev"
# https://docs.kernel.org/admin-guide/initrd.html
# https://gitlab.alpinelinux.org/alpine/mkinitfs
# https://wiki.gentoo.org/wiki/Custom_Initramfs
# https://www.linuxfromscratch.org/blfs/view/svn/postlfs/initramfs.html
#
# if a CPU microcode is needed, prepend it to initramfs
# https://docs.kernel.org/arch/x86/microcode.html
# https://wiki.archlinux.org/title/Microcode

# wireless-regdb
# https://wireless.wiki.kernel.org/en/developers/regulatory/wireless-regdb
