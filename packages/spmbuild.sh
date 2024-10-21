project_dir="$(dirname "$0")"

# https://git.alpinelinux.org/aports/tree/main/busybox
# https://git.busybox.net/busybox/tree/
# https://www.busybox.net/downloads/BusyBox.html
# git://busybox.net/busybox/tag/?h=1_36_1

# disable these:
# who, last, FEATURE_UTMP, wget, ntpd, diff and cmp
# less, man, su, blkid
# mdev-daemon ifupdown

# define these macros when compiling busybox:
#define _PATH_PASSWD /spm/"$gnunet_namespace"/system/data/passwd
#define _PATH_GROUP /spm/"$gnunet_namespace"/system/data/group
#define _PATH_SHADOW /spm/"$gnunet_namespace"/system/data/shadow
#define _PATH_GSHADOW /spm/"$gnunet_namespace"/system/data/gshadow

# https://smarden.org/runit/
# https://man.voidlinux.org/runsvdir.8
# https://git.alpinelinux.org/aports/tree/main/openrc
#
# init
# PATH=/apps/bb:/apps
# run bb services
# mount a tmpfs in /run and /tmp

# do not enable ntpd service

# sudo addrule for rfkill

# login service
# at login:
# , mkdir -p /run/user/$user_id
# , chmod 700 /run/user/$user_id
# , export XDG_RUNTIME_DIR=/run/user/$user_id
# , run services at /apps/sv as the user, supervised
# copy "loginit.sh" to "login" in the build dir, under sv dir

# https://docs.voidlinux.org/
#
# https://wiki.artixlinux.org/Main/Installation
# https://gitea.artixlinux.org/artix
# https://packages.artixlinux.org/
#
# https://docs.alpinelinux.org/user-handbook/0.1a/Installing/setup_alpine.html
# https://gitlab.alpinelinux.org/alpine
# https://gitlab.alpinelinux.org/alpine/alpine-conf
# https://pkgs.alpinelinux.org/package/edge/main/x86_64/alpine-base
#
# https://github.com/glasnostlinux/glasnost
# https://www.linuxfromscratch.org/ https://www.linuxfromscratch.org/lfs/view/stable/
# https://github.com/iglunix
# https://github.com/gobolinux
# https://github.com/oasislinux/oasis
# https://sta.li/
# https://t2sde.org/handbook/html/index.html
# https://buildroot.org/downloads/manual/manual.html
