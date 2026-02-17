# usage: sh mkinst.sh [<device-name> [<arch>]]
echo "this will create a bootable Uni installer, on a removable storage device"

script_dir="$(dirname "$(readlink -f "$0")")"

# name of the target device to write the installer on
# it's an optional argument
# if empty, this script will be interactive, and will allow the user to choose the target device
target_device="$1"

arch="$2"
[ -n "$1" ] && [ -z "$2" ] && arch="$(uname -m)"
while [ -z "$arch" ]; do
	echo "the following architectures are supported:"
	echo "	1) x86_64"
	echo "	2) aarch64"
	echo "	3) riscv64"
	echo "enter the number of the desired architechture: "
	read -r ans
	case "$ans" in
	1) arch=x86_64 ;;
	2) arch=aarch64 ;;
	3) arch=riscv64 ;;
	esac
done

wdir=/var/cache/upm/mkinst
mkdir -p "$wdir"
cd "$wdir"

mkdir -p target
trap "trap - EXIT; umount -q target; rmdir target" EXIT INT TERM QUIT HUP PIPE

sh "$script_dir"/mkfs.sh fat "$wdir/target" "$target_device" || exit

. "$script_dir"/mkinst-alpine.sh; exit

# bootstraping and cross compilation
# https://www.linuxfromscratch.org/lfs/view/stable/
# https://t2sde.org/handbook/html/index.html
# https://buildroot.org/downloads/manual/manual.html
# https://github.com/glasnostlinux/glasnost
# https://github.com/iglunix
# https://github.com/oasislinux/oasis
# https://mcilloni.ovh/2021/02/09/cxx-cross-clang/

# create  an initramfs (for $arch) that includes programs needed to install Uni
# https://wiki.alpinelinux.org/wiki/How_to_make_a_custom_ISO_image_with_mkimage
mkdir initfs
# init, login as root, run install.sh

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
upm
tpm2-tools
util-linux
codev-shell
codev' | while read -r pkg_name; do
	ROOT_DIR="$wdir"/initfs sh "$script_dir"/upm.sh install "$pkg_name"
done

echo "bootable Uni installer successfully created"
echo "now boot into the installation media, and follow the instructions"
