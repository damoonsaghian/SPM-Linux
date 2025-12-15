# https://pkgs.alpinelinux.org/package/edge/main/x86_64/util-linux
# https://git.kernel.org/pub/scm/utils/util-linux/util-linux.git/tree/
# https://git.kernel.org/pub/scm/utils/util-linux/util-linux.git/tree/meson_options.txt
# mount umount libmount mountpoint lsblk blkid libblkid uuidgen libuuid blkdiscard blkzone blockdev sfdisk fdisk libfdisk
# exch findfs findmnt mkswap swapon swapoff eject losetup fallocate wipefs flock fstrim
# dmesg setpriv pivot_root switch_root unshare hwclock rfkill renice taskset rtcwake
# lscpu lsmem
# disable: su runuser login mcookie logger partx cfdisk setarch ...

# https://github.com/shadow-maint/shadow
# without pam
# -D PASSWD_FILE=\"/var/etc/passwd\"

# add user "home" with home at "/home" and shell "/usr/bin/codev-shell"

# agetty service for vt1: /usr/bin/agetty --autologin home tty1 linux
# agetty service for vt2: /usr/bin/agetty --autologin home tty2 linux

echo '#!/usr/bin/env sh
# run dinit user services, like pipewire, wireplumber, and dbus
# https://manpages.debian.org/trixie/dbus-daemon/dbus-daemon.1.en.html
' > /usr/bin/home-services
chmod +x /usr/bin/home-services

# https://git.kernel.org/pub/scm/linux/kernel/git/kdave/btrfs-progs.git/about/
# https://github.com/dosfstools/dosfstools
# https://github.com/exfatprogs/exfatprogs

# suspend system with support for hooks (needed for some drivers)
# https://github.com/jirutka/zzz
# doas rules
