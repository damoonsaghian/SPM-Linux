# installs a minimal system based on Alpine Linux, providing a user interface using UShell and Uni
# https://gitlab.alpinelinux.org/alpine/alpine-conf
# https://gitlab.alpinelinux.org/alpine/aports/-/tree/master/main/alpine-baselayout
# https://gitlab.alpinelinux.org/alpine/aports/-/tree/master/main/openrc
# https://gitlab.alpinelinux.org/alpine/aports/-/tree/master/main/busybox

# if this script is run by any user other than root, just install "upm" to user's home directory, and exit
if [ $(id -u) != 0 ]; then
	# https://gitlab.postmarketos.org/postmarketOS/coldbrew
	# https://gitlab.postmarketos.org/postmarketOS/coldbrew/-/blob/main/coldbrew
fi

mkdir -p "$new_root"/dev "$new_root"/proc
mount --bind /dev "$new_root"/dev
mount --bind /proc "$new_root"/proc

mkdir -p "$new_root"/usr/bin "$new_root"/usr/sbin "$new_root"/usr/lib
ln -s usr/bin usr/sbin usr/lib var/etc "$new_root"/

mkdir -p "$new_root"/etc/apk/keys/
cp /etc/apk/keys/* "$new_root"/etc/apk/keys/

mkdir -p "$new_root"/etc/apk
echo 'https://dl-cdn.alpinelinux.org/alpine/edge/main
https://dl-cdn.alpinelinux.org/alpine/edge/community
@testing https://dl-cdn.alpinelinux.org/alpine/edge/testing
' > "$new_root"/etc/apk/repositories

apk_new() {
	apk --repositories-file "$new_root"/etc/apk/repositories --root "$new_root" --quiet --progress add "$@"
}

rc_new() {
	local service runlevel
	if [ "$1" = --nu ]; then
		service="$2"
		runlevel="$3"
		[ -z "$service" ] && return
		[ -z "$runlevel" ] && runlevel=sysinit
		ln -s /etc/user/init.d/"$service" "$new_root"/nu/.config/rc/runlevels/"$runlevel"/
	else
		service="$1"
		runlevel="$2"
		[ -z "$service" ] && return
		[ -z "$runlevel" ] && runlevel=default
		ln -s /etc/init.d/"$service" "$new_root"/etc/runlevels/"$runlevel"/
	fi
}

apk_new alpine-base
rc_new devfs sysinit
rc_new dmesg sysinit
rc_new bootmisc boot
rc_new hostname boot
rc_new hwclock boot
rc_new modules boot
rc_new seedrng boot
rc_new sysctl boot
rc_new syslog boot # in busybox
rc_new cgroups
rc_new savecache shutdown
rc_new killprocs shutdown
rc_new mount-ro shutdown

apk_new eudev eudev-netifnames earlyoom acpid zzz bluez \
	networkmanager-cli wireless-regdb mobile-broadband-provider-info ppp-pppoe dnsmasq chrony dcron fwupd
rc_new udev sysinit
rc_new udev-trigger sysinit
rc_new udev-settle sysinit
rc_new udev-postmount
rc_new earlyoom
rc_new acpid
rc_new bluetooth
rc_new networkmanager
rc_new networkmanager-dispatcher
rc_new chronyd
rc_new dcron
rc_new fwupd

cp -r "$script_dir" "$new_root"/usr/local/share/
chmod +x "$new_root"/usr/local/share/upm/upm.sh
ln -s /usr/local/share/upm/upm.sh "$new_root"/usr/local/bin/spm
mkdir -p "$new_root"/etc/doas.d
echo 'permit nopass nu cmd /usr/local/bin/upm' > "$new_root"/etc/doas.d/upm.conf
echo '* * * * * ID=autoupdate FREQ=1d/5m upm autoupdate' > "$new_root"/etc/cron.d/upm-autoupdate

cp -r "$script_dir"/../ushare "$new_root"/usr/local/share/
chmod +x "$new_root"/usr/local/share/ushare/ushare.sh
ln -s /usr/local/share/ushare/ushare.sh "$new_root"/usr/local/bin/ushare

cp -r "$script_dir"/../upkgs/ "$new_root"/usr/local/share/

# https://wiki.archlinux.org/title/Laptop_Mode_Tools
# https://github.com/rickysarraf/laptop-mode-tools
# https://github.com/rickysarraf/laptop-mode-tools/blob/lmt-upstream/Documentation/laptop-mode.txt
# https://github.com/rickysarraf/laptop-mode-tools/wiki
# use xrandr to lower screen refresh rate, when on battery

##########
#  boot  #
##########

echo "disable_trigger=yes" > "$new_root"/etc/mkinitfs/mkinitfs.conf

echo '#!/bin/sh
if [ "$1" = "pre-commit" ]; then
    true
elif [ "$1" = "post-commit" ]; then
	[ -f /boot/vmlinuz-stable ] && mv /boot/vmlinuz-stable /boot/vmlinuz
	efi_path="$(echo /usr/lib/systemd/boot/efi/system-boot*.efi)"
    [ -f "$efi_path" ] && mv "$efi_path" /boot/
fi
' > "$new_root"/etc/apk/commit_hooks.d/create-boot-files
chmod +x "$new_root"/etc/apk/commit_hooks.d/create-boot-files

apk_new linux-stable systemd-boot mkinitfs btrfs-progs cryptsetup tpm2-tools
case "$(uname -m)" in
x86*)
	cpu_vendor_id="$(cat /proc/cpuinfo | grep vendor_id | head -n1 | sed -n "s/vendor_id[[:space:]]*:[[:space:]]*//p")"
	[ "$cpu_vendor_id" = AuthenticAMD ] && apk_new amd-ucode
	[ "$cpu_vendor_id" = GenuineIntel ] && apk_new intel-ucode
;;
esac

chmod +x "$new_root"/usr/local/share/codev-util/tpm-getkey.sh
ln -s /usr/local/share/codev-util/tpm-getkey.sh "$new_root"/usr/local/bin/tpm-getkey

chroot "$new_root" sh /usr/local/share/systemd-boot/bootup.sh

##########
#  user  #
##########

echo; echo "set root password (can be the same as he one used to encrypt the root partition)"
echo "WARNING! do not use this password carelessly"
echo "in practice, it's only required for manually changing system files, ie almost never"
while ! chroot "$new_root" passwd root; do
	echo "please retry"
done

# create a normal user
chroot "$new_root" adduser --empty-password --no-create-home --home /nu --shell /usr/local/bin/ushell nu
btrfs subvolume create "$new_root/nu"
chroot "$new_root" chown nu: /nu

echo; echo "set lock'screen password"
while ! chroot "$new_root" passwd nu; do
	echo "please retry"
done

sed 's@tty1:respawn:\(.*\)getty@tty1:respawn:\1getty -n -l /usr/local/bin/autologin@' \
	"$new_root"/etc/inittab > "$new_root"/etc/inittab.tmp
sed 's@tty2:respawn:\(.*\)getty@tty2:respawn:\1getty -n -l /usr/local/bin/autologin@' \
	"$new_root"/etc/inittab.tmp > "$new_root"/etc/inittab

ln -s /usr/local/share/util-linux/autologin.sh "$new_root"/usr/local/bin/autologin
chmod +x "$new_root"/usr/local/share/util-linux/autologin.sh

############
#  Ushell  #
############

if apk info quickshell >/dev/null 2>&1; then
	apk_new quickshell --virtual .quickshell
else
	apk_new git clang cmake ninja-is-really-ninja pkgconf spirv-tools wayland-protocols qt6-qtshadertools-dev \
		jemalloc-dev pipewire-dev libdrm-dev mesa-dev wayland-dev \
		qt6-qtbase-dev qt6-qtdeclarative-dev qt6-qtsvg-dev qt6-qtwayland-dev --virtual .quickshell
		chroot "$new_root" sh "$script_dir"/upm.sh quickshell
fi
apk_new setpriv doas-sudo-shim musl-locales exfatprogs tzdata geoclue bash bash-completion dbus \
	pipewire pipewire-pulse pipewire-alsa pipewire-echo-cancel pipewire-spa-bluez wireplumber sof-firmware \
	mesa-dri-gallium mesa-va-gallium breeze breeze-icons \
	font-adobe-source-code-pro font-noto font-noto-emoji \
	font-noto-armenian font-noto-georgian font-noto-hebrew font-noto-arabic font-noto-ethiopic font-noto-nko \
	font-noto-devanagari font-noto-gujarati font-noto-telugu font-noto-kannada font-noto-malayalam \
	font-noto-oriya font-noto-bengali font-noto-tamil font-noto-myanmar \
	font-noto-thai font-noto-lao font-noto-khmer font-noto-cjk \
	qt6-qtvirtualkeyboard qt6-qtsensors mauikit-terminal .quickshell --virtual .codev-shell
rc_new dbus
rc_new --nu dbus
rc_new --nu pipewire
rc_new --nu wireplumber

cp -r "$script_dir"/../codev-shell "$new_root"/usr/local/share/codev-shell
chmod +x "$new_root"/usr/local/share/codev-shell/codev-shell.sh
ln -s "$new_root"/usr/local/share/codev-shell/codev-shell.sh "$new_root"/usr/local/bin/codev-shell

cat <<-EOF > "$new_root"/etc/doas.d/codev-shell.conf
permit nopass nu cmd setpriv --reuid=nu --regid=nu --groups=input,video,audio /usr/local/bin/codev-shell priv
permit nopass nu cmd /usr/bin/passwd nu
EOF

echo '#!/bin/sh
case "$2" in
up) sudo -u nu sh /usr/local/share/codev-shell/system.sh tz guess ;;
esac
' > /etc/NetworkManager/dispatcher.d/09-dispatch-script
chmod 755 /etc/NetworkManager/dispatcher.d/09-dispatch-script

#########
#  Uni  #
#########

apk_new mauikit mauikit-filebrowsing mauikit-texteditor mauikit-imagetools mauikit-documents \
	kio-extras kimageformats qt6-qtsvg \
	qt6-qtmultimedia ffmpeg-libavcodec qt6-qtwebengine qt6-qtlocation geoclue qt6-qtremoteobjects qt6-qtspeech \
	qt6-qtcharts qt6-qtgraphs qt6-qtdatavis3d qt6-qtquick3d qt6-qt3d qt6-qtquicktimeline \
	gnunet aria2 openssh --virtual .codev
# qt6-qtquick3dphysics qt6-qtlottie
cp -r "$script_dir"/../uni "$new_root"/usr/local/share/
mkdir -p "$new_root"/usr/local/share/icons/hicolor/scalable/apps
ln -s /usr/local/share/uni/data/uni.svg "$new_root"/usr/local/share/icons/hicolor/scalable/apps/

mkdir -p "$new_root"/usr/local/share/applications
echo '[Desktop Entry]
Name=Codev
Comment=Collaborative Development
Icon=codev
exec=qml6 /usr/local/share/codev/main.qml
StartupNotify=true
Type=Application
' > "$new_root"/usr/local/share/applications/codev.desktop

chmod +x "$new_root"/usr/local/share/uni/sd.sh
ln -s /usr/local/share/uni/sd.sh "$new_root"/usr/local/bin/sd
echo 'permit nopass nu cmd /usr/local/bin/sd' > "$new_root"/etc/doas.d/sd.conf

echo; echo "installation completed successfully"
printf "reboot the system? (Y/n) "
read -r ans
[ "$ans" != n ] && [ "$ans" != no ] && reboot
