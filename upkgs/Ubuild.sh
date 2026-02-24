pkg=acpid

# listen for, and process, ACPI events related to lid-switch activation and the power and suspend keys
# https://wiki.archlinux.org/title/Acpid
# https://wiki.alpinelinux.org/wiki/Power_management
# https://gitlab.alpinelinux.org/alpine/aports/-/tree/master/main/acpid

pkg=archive

# https://github.com/libarchive/libarchive
# --with-nettle --without-openssl

# https://github.com/bramp/archivemount

pkg=aria2

# https://github.com/aria2/aria2

# --enable-libaria2
# --without-sqlite3 --without-libxml2 --without-libexpat --without-libcares --without-libz
# --without-libssh2 --disable-ssl --disable-metalink --disable-websocket
# ENABLE_XML_RPC=false
# Enable_ASYNC_DNS=false
# in src/Makefile.am remove these files: Ftp*.cc Http*.cc AbstractHttp*.cc AbstractProxy*.cc

# torrents do in'place first'write for preallocated space
# BTRFS can do in'place writes for a file by disabling COW
# but we don't want to disable COW for these files (unlike databases and virtual machine images)
# apparently BTRFS supports in'place first'write (falloc) without disabling COW, isn't it?
# https://www.reddit.com/r/btrfs/comments/timsw2/clarification_needed_is_preallocationcow_actually/
# https://www.reddit.com/r/btrfs/comments/s8vidr/how_does_preallocation_work_with_btrfs/

pkg=avahi

# skip avahi-glib

pkg=bash

# bash (for interactive shell)
# https://cgit.git.savannah.gnu.org/cgit/bash.git

pkg=bluez

# https://www.bluez.org/
# https://pkgs.alpinelinux.org/package/edge/main/x86_64/bluez
# needs glib; link it statically

# doas rule

pkg=chrony

# https://chrony-project.org/documentation.html
# https://gitlab.com/chrony/chrony
# do not

# how to sync time over gnunet? vpn over gnunet maybe?

pkg=clang

upm_import llvm

gitag_clone

pkg=cryptsetup

# with nettle backend

pkg=curl

# http/https only curl (with gnutls backend)

# for http/3:
# https://github.com/ngtcp2/ngtcp2
# https://github.com/lxin/quic (only works on linux)

pkg=dbus

# https://man.archlinux.org/listing/dbus

# in system.conf:
# <includedir>/usr/share/dbus-1</includedir>
# <servicedir>/usr/share/dbus-1/services</servicedir>
# in session.conf:
# <includedir>$XDG_DATA_HOME/dbus-1</includedir>
# <servicedir>$XDG_DATA_HOME/dbus-1/services</servicedir>

# /usr/share/dbus-1/session.conf
# /usr/share/dbus-1/session.d/
# /usr/share/dbus-1/services/

# https://github.com/chimera-linux/dbus-wait-for
# https://git.sr.ht/~whynothugo/dbus-waiter

pkg=dinit

# https://github.com/davmac314/dinit

# init
# run services
# mount a tmpfs in /run and /tmp
# PATH=/usr/bin

# chimera linux
# https://wiki.artixlinux.org/Main/Installation
# https://gitea.artixlinux.org/artix
# https://packages.artixlinux.org/
#
# https://github.com/glasnostlinux/glasnost
# https://github.com/iglunix
# https://github.com/oasislinux/oasis

# doas rules for: dinit-poweroff, dinit-reboot

pkg=sudoas

# https://github.com/Duncaen/OpenDoas

# https://manpages.debian.org/trixie/opendoas/doas.conf.5.en.html
# setenv TZ

# sudo wrapper

pkg=dte

# terminal text editor
# https://gitlab.com/craigbarnes/dte

# https://gitlab.com/craigbarnes/dte/-/blob/master/docs/packaging.md
# make ICONV_DISABLE=1 BUILTIN_SYNTAX_FILES='dte config ini sh'

pkg=eudev

# https://github.com/eudev-project/eudev

# skip eudev-hwids
# https://pkgs.alpinelinux.org/package/edge/main/x86_64/eudev-hwids

# https://pkgs.alpinelinux.org/package/edge/main/x86_64/eudev-netifnames

# when creating /dev/input devices, set their group to 1
# when creating /dev/dri devices, set their group to 2
# when creating /dev/snd/* and /dev/video* devices, set their group to 1000

# to prevent BadUSB, cerate evdev rule that when a new input device is connected:
# touch /tmp/lock-bash
# chown 1000 /tmp/lock-bash

pkg=ffmpeg

# https://git.ffmpeg.org/ffmpeg.git

# use libpw-v4l2.so instead of libv4l2.so

pkg=fontconfig

# mono'space fonts:
# , wide characters are forced to squeeze
# , narrow characters are forced to stretch
# , bold characters don't have enough room
# proportional font for code:
# , generous spacing
# , large punctuation
# , and easily distinguishable characters
# , while allowing each character to take up the space that it needs
# Iosevka Aile (just change "I" character)
# "https://github.com/iaolo/iA-Fonts/tree/master/iA%20Writer%20Quattro" (just change "I" character)

# monospace font is still needed for terminal emulator
# https://github.com/adobe-fonts/source-code-pro

# noto fonts for: math, symbols, emoji, armenian georgian hebrew arabic ethiopic nko,
# 	devanagari gujarati telugu kannada malayalam oriya bengali tamil myanmar thai lao khmer cjk

pkg=geoclue

upm_import netman # for modemmanager

# https://gitlab.freedesktop.org/geoclue/geoclue
# libgeoclue=false introspection=false gtk-doc=false
# wifi-source=false wifi-source=false 3g-source=false ip-source=false
# avahi-glib: build and statically link

pkg=git

# https://github.com/git/git/blob/master/INSTALL
# https://github.com/git/git/blob/master/Makefile

# git clones are done in /var/cache/git/clones/
# the dir is writable only for users in group 11
# git has its GUID set for group 11

pkg=gmp

pkg=gnunet

# https://git.gnunet.org/gnunet.git/tree/src

cp "$script_dir"/gnunet.conf "$project_dir"/.cache/upm/

# intresting fact: gnunet uses UDP to discover peers on local net

# https://docs.gnunet.org/latest/users/configuration.html#limitations-and-known-bugs
# https://docs.gnunet.org/latest/users/subsystems.html#transport-ng-next-generation-transport-management
# https://en.wikipedia.org/wiki/Long-range_Wi-Fi

# LoRa communicator for emergency communications (when normal network infrastructure is down)
# https://en.wikipedia.org/wiki/LoRa
# actually a separate LoRa device can by itself be useful in emergency situations
# 	normally it should have a rechargable battery, and a manual switch too

# for now, build libsodium and gcrypt internally, and link statically
# it will be good if GNUnet replaces them with nettle
# and even add NTRU on top, for more security (like in openssh)

pkg=gnutls

upm_import nettle

# https://pkgs.alpinelinux.org/package/edge/main/x86_64/ca-certificates-bundle

# disable p11-kit, cause it's useless
# because when a system is compromized, though it can protect the private key itself,
# it can't prevent using the private key (eg for signing)

# build the openssl compatibility wrapper

pkg=harfbuzz

# disable glib

pkg=icu

# https://github.com/unicode-org/icu
# https://pkgs.alpinelinux.org/package/edge/main/x86_64/icu-data-en

pkg=kf

# KDE framworks
# kio, syntax-highlighting, and all KF addons that they need
# https://invent.kde.org/libraries/kquickimageeditor

# build karchive without libcrypto dependency

# https://invent.kde.org/frameworks/solid
# udev backend (no udisks)
# no upower BUILD_DEVICE_BACKEND_upower

# libmtp without gcrypt
# https://sourceforge.net/p/libmtp/code/ci/master/tree/INSTALL

pkg=libc

# for linux build musl
# for others skip build, and just symlink the libc on the system

# https://git.adelielinux.org/adelie/musl-locales
# put the generated locale files in $pkg_dir/locale/

# mimalloc

pkg=libc++

# https://libcxx.llvm.org/

pkg=linux
# https://kernel.org/

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

# self signed unified kernel image
# https://wiki.archlinux.org/title/Unified_kernel_image
# https://wiki.archlinux.org/title/Unified_Extensible_Firmware_Interface/Secure_Boot#Using_your_own_keys

# wireless-regdb
# https://wireless.wiki.kernel.org/en/developers/regulatory/wireless-regdb

pkg=llvm

# https://llvm.org/docs/GettingStarted.html
# https://gitlab.alpinelinux.org/alpine/aports/-/tree/master/main/llvm-runtimes

pkg=mauikit

upm_import kf

# https://invent.kde.org/maui

# filebrowsing texteditor imagetools terminal
# documents (pdf viewer using qt-poppler)

pkg=mpfr

# https://gitlab.inria.fr/mpfr/mpfr.git

pkg=netman

# https://gitlab.freedesktop.org/NetworkManager/NetworkManager
# it requires glib; link it statically
# crypto=gnutls polkit=false
# https://gitlab.freedesktop.org/NetworkManager/NetworkManager/-/blob/main/meson_options.txt
# change the path of /etc/resolv.conf generated by network manager
# is /etc/hosts required?

# wpa_supplicant or iwd (without dhcp)

# https://gitlab.freedesktop.org/mobile-broadband/ModemManager

# in src/nm-dispatcher/nm-dispatcher.c replace:
# _find_scripts(request, scripts, NMLIBDIR, subdir);
# with:
# _find_scripts(request, scripts, "/usr/share/NetworkManager", subdir);

pkg=nettle

# https://git.lysator.liu.se/nettle/nettle

pkg=openssl

# not a fan actually, but tmp2-tss and qtnetwork depend on it

pkg=pipewire

# https://gitlab.freedesktop.org/pipewire/pipewire
# https://wiki.alpinelinux.org/wiki/PipeWire
# https://docs.voidlinux.org/config/media/pipewire.html
# https://wiki.archlinux.org/title/PipeWire

# https://gitlab.freedesktop.org/pipewire/media-session

# pulse
# without gstreamer glib jack

# libpw-v4l2.so

# pipewire-spa-bluez

pkg=qt

# https://github.com/qt/qtbase
# https://github.com/qt/qtbase/blob/dev/config_help.txt
# cmake args: -DFEATURE_glib=OFF -DFEATURE_xcb_xlib=OFF

# https://github.com/qt/qtdeclarative

# gnutls implementes a compatibility wrapper for openssl; try to use that
# if it failed, use openssl
#
# QtNetwork depends on openssl and does not support HTTP3
# it would be good to reimplement it using Curl, in the future
# https://doc.qt.io/qt-6/qtnetwork-module.html
# https://curl.se/libcurl/c/

# https://github.com/qt/qtimageformats
# https://github.com/qt/qtsvg
# https://invent.kde.org/frameworks/kimageformats/

pkg=qt-3d

# https://github.com/qt/qt3d

pkg=qt-charts

# https://github.com/qt/qtcharts

pkg=qt-datavisualization

# https://github.com/qt/qtdatavis3d

pkg=qt-graphs

# https://github.com/qt/qtgraphs

pkg=qt-location

upm_import qt-positioning

# OpenStreetMap viewer
# https://github.com/qt/qtlocation

pkg=qt-lottie

# https://github.com/qt/qtlottie

pkg=qt-multimedia

# https://github.com/qt/qtmultimedia/tree/dev

# ffmpeg backend https://github.com/qt/qtmultimedia/blob/dev/src/plugins/multimedia/ffmpeg/CMakeLists.txt
# 	disable QT_FEATURE_xlib
# https://github.com/qt/qtmultimedia/blob/dev/src/multimedia/CMakeLists.txt
# enable alsa, disable pulse

pkg=qt-poppler

# https://gitlab.freedesktop.org/poppler/poppler
# https://gitlab.freedesktop.org/poppler/poppler/-/blob/master/CMakeLists.txt
# ENABLE_NSS3=OFF ENABLE_GPGME=OFF ENABLE_QT5=OFF ENABLE_GLIB=OFF

pkg=qt-positioning

upm_import qt-serialport # for NMEA plugin
upm_import qt-geoclue

# https://github.com/qt/qtpositioning

pkg=qt-quick3d

# https://github.com/qt/qtquick3d

pkg=qt-quick3dphysics

# https://github.com/qt/qtquick3dphysics

pkg=qt-quicktimeline

# https://github.com/qt/qtquicktimeline

pkg=qt-remoteobjects

# https://github.com/qt/qtremoteobjects

pkg=qt-sensors

# https://github.com/qt/qtsensors
# https://github.com/qt/qtsensors/tree/dev/src/plugins/sensors/sensorfw
# https://github.com/sailfishos/sensorfw
# https://github.com/sailfishos/sensorfw/blob/master/doc/PLUGIN-GUIDE

pkg=qt-serialport

# https://github.com/qt/qtserialport

pkg=qt-speech

# https://github.com/qt/qtspeech
# with flite backend

pkg=qt-wayland

# https://github.com/qt/qtwayland

pkg=qt-webkit

# https://github.com/movableink/webkit
# https://github.com/movableink/webkit/blob/master/Source/cmake/OptionsQt.cmake

# https://github.com/qt/qtwebchannel

# link gcrypt statcally
# or replace it with nettle:
# https://blog.cranksoftware.com/webkit-porting-tips-the-good-the-bad-and-the-ugly/
# https://ariya.io/2011/06/your-webkit-port-is-special-just-like-every-other-port
# https://trac.webkit.org/wiki/SuccessfulPortHowTo
# https://trac.webkit.org/wiki/WikiStart
# https://github.com/WebKit/WebKit/blob/main/Source/cmake/OptionsGTK.cmake

pkg=quickshell

upm_import qt-wayland

# https://git.outfoxxed.me/quickshell/quickshell
# https://git.outfoxxed.me/quickshell/quickshell/src/branch/master/BUILD.md
# -DSERVICE_PAM=OFF

pkg=ssh

# https://git.lysator.liu.se/lsh/lsh
# https://www.lysator.liu.se/~nisse/lsh/lsh.html

# create ssh and and ssh-keygen executables
# provide at least those options needed by git and upm
# or
# configure git to use ssh program in a way that is compatible with lsh:
# https://github.com/git/git/blob/master/Documentation/config/ssh.adoc

pkg=systemd-boot

pkg=tpm2-tools

# https://github.com/tpm2-software/tpm2-tools

# gnutls implementes a compatibility wrapper for openssl; try to use that
# if it failed, use openssl

# tmp-getkey.sh

pkg=utils

# https://git.busybox.net/busybox/tree
# -D _PATH_PASSWD=\"/var/etc/passwd\" -D _PATH_GROUP=\"/var/etc/group\" -D _PATH_SHADOW=\"/var/etc/shadow\"
# https://gitlab.alpinelinux.org/alpine/aports/-/blob/master/main/busybox/busyboxconfig
# enable: rtcwake
# disable: *mount* *volumid* eject fstrim *blk* blockdev findfs *fdisk* *_label *swap*

# for mount and block device commands, use util-linux instead
# https://pkgs.alpinelinux.org/package/edge/main/x86_64/util-linux
# https://git.kernel.org/pub/scm/utils/util-linux/util-linux.git/tree/meson_options.txt
# https://git.kernel.org/pub/scm/utils/util-linux/util-linux.git/tree/
# mount umount libmount mountpoint findmnt eject fstrim
# lsblk blkid libblkid blkdiscard blkzone blockdev findfs wipefs
# fdisk libfdisk mkswap swapon swapoff
# uuidgen libuuid
# lscpu lsmem
# disable: su runuser login mcookie logger partx sfdisk cfdisk setarch ...

# create executable from autologin.sh
# getty service for tty1: /usr/bin/getty -n -l /usr/bin/autologin 38400 tty1
# getty service for tty2: /usr/bin/getty --skip-login -l /usr/bin/autologin tty2 linux

cp "$script_dir"/autologin.sh /usr/bin/autologin
chmod +x /usr/bin/autologin

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
